# C++17/Qt 系统级排错 (System Debugging & Stabilization)

这个 skill 用于系统性地分析、定位和修复 Qt 5.15/C++17 架构下的缺陷。不仅关注"修复崩溃"，更致力于**消除未定义行为 (UB)** 并通过**类型系统**强化代码健壮性。

## 适用场景

- **内存安全**：悬空指针、野指针、内存泄漏、Double Free
- **并发异常**：死锁、数据竞争 (Data Race)、原子性破坏
- **系统行为**：未定义行为 (UB)、ABI 兼容性问题、栈溢出
- **Qt 特性**：信号槽死循环、跨线程通信失败、QObject 生命周期管理失误

---

## 核心流程 (The Workflow)

### 第一步：现象锚定与复现 (Anchoring)

在复现问题前，必须明确问题的边界。

#### 1.1 环境指纹

| 信息类型 | 收集内容 |
|---------|---------|
| **操作系统** | Windows/Linux/macOS 及版本 |
| **编译器** | MSVC/GCC/Clang 及版本 |
| **Qt 版本** | Qt 5.15.x |
| **构建类型** | Debug / Release / RelWithDebInfo |
| **架构** | x86 / x64 / ARM |

#### 1.2 最小复现路径 (MVP)

```
1. 剥离无关逻辑
2. 构建最小可复现代码片段 (MCVE)
3. 确定触发条件
```

#### 1.3 确定性验证

| 类型 | 特征 | 调试策略 |
|-----|------|---------|
| **必现 (Deterministic)** | 相同操作总是触发 | 断点调试、日志追踪 |
| **偶发 (Heisenbug)** | 时机相关、难以复现 | Sanitizers、压力测试 |

---

### 第二步：笛卡尔式根因分析 (Cartesian Analysis)

使用"怀疑论"逐层拷问代码，结合 C++17 标准与 Qt 机制。

#### 2.1 架构级拷问清单

##### 所有权 (Ownership)
- [ ] 谁拥有这个资源？
- [ ] 是用 `std::unique_ptr` 管理的吗？
- [ ] 是否存在裸指针 (`T*`) 越权释放？

##### 生命周期 (Lifetime)
- [ ] `lambda` 捕获的 `this` 或引用变量是否比 lambda 执行活得更久？
- [ ] `std::string_view` 指向的内存是否已被释放？
- [ ] 返回的引用/指针指向的对象是否仍然存活？

##### 线程安全 (Concurrency)
- [ ] 是否在无锁状态下访问了 `static` 或共享变量？
- [ ] 是否使用了 `std::scoped_lock` 避免死锁？
- [ ] 跨线程传递的数据是否正确同步？

##### Qt 机制
- [ ] 是否在非 UI 线程操作了 `QWidget`？
- [ ] 信号槽连接是否检查了返回值？
- [ ] QObject 的父子关系是否正确设置？

##### 未定义行为 (UB)
- [ ] 是否存在有符号整数溢出？
- [ ] 是否违反了 Strict Aliasing 规则？
- [ ] 是否访问了未初始化的变量？

---

### 第三步：C++17 现代化根因分类与修复

#### 1. 内存与生命周期问题

**架构原则**：禁止手动 `new/delete`，强制 RAII。

| Bug 类型 | 传统/错误写法 | C++17 架构师修复方案 |
|---------|-------------|---------------------|
| **无效/空值处理** | `Widget* w = get(); if (w) ...` (指针语义模糊) | **`std::optional<Widget>`** 明确表达"可能无值"，强迫调用者处理 |
| **悬空引用** | 保存了 `const string&` 却销毁了源 | **`std::string_view`** (仅参数传递)，存储时必须拷贝为 `std::string` |
| **Qt 对象悬空** | `Widget* m_w; ... m_w->func();` | **`QPointer<Widget> m_w;`** Qt 专用弱引用，对象销毁后自动置空 |
| **资源泄漏** | `T* p = new T(); ... delete p;` | **`std::unique_ptr<T>`** RAII 自动管理 |

**代码示例：修复"资源可能无效"的逻辑**

```cpp
// ❌ 劣质代码：依赖裸指针判空，容易遗漏
Widget* findWidget(int id);
void process() {
    Widget* w = findWidget(10);
    w->show(); // 💥 如果 w 为空，直接崩溃
}

// ✅ C++17 重构：利用类型系统强制检查
std::optional<std::reference_wrapper<Widget>> findWidget(int id);

void process() {
    auto result = findWidget(10);
    if (result.has_value()) {
        result->get().show();
    } else {
        // 必须显式处理"未找到"的情况
        qWarning() << "Widget not found";
    }
}
```

**代码示例：修复悬空指针**

```cpp
// ❌ 劣质代码：裸指针，生命周期不明确
class Controller {
    Worker* m_worker;  // 谁负责销毁？
public:
    ~Controller() {
        delete m_worker;  // 如果已被其他地方删除？💥
    }
};

// ✅ C++17 重构：明确所有权
class Controller {
    std::unique_ptr<Worker> m_worker;  // Controller 独占所有权
public:
    ~Controller() = default;  // unique_ptr 自动清理
};

// ✅ Qt 风格：使用对象树或 QPointer
class Controller : public QObject {
    QPointer<Worker> m_worker;  // 弱引用，自动检测销毁
public:
    void process() {
        if (m_worker) {  // 安全检查
            m_worker->doWork();
        }
    }
};
```

#### 2. 并发与死锁问题

**架构原则**：原子化锁获取，避免手动管理锁顺序。

| Bug 类型 | 传统/错误写法 | C++17 架构师修复方案 |
|---------|-------------|---------------------|
| **死锁** | `lock(A); lock(B);` (顺序不一致) | **`std::scoped_lock lock(mutexA, mutexB);`** 算法保证多锁安全 |
| **读写竞争** | `std::mutex` 保护读多写少数据 | **`std::shared_mutex`** + `shared_lock` 提升读并发 |
| **忘记解锁** | 手动 `lock()/unlock()` | **RAII 锁**: `std::lock_guard` / `std::scoped_lock` |

**代码示例：安全锁机制**

```cpp
// ❌ 劣质代码：容易遗忘 unlock，或因异常导致死锁
mtx.lock();
doSomething();
if (error) return; // 💥 忘记 unlock，死锁！
mtx.unlock();

// ✅ C++17 重构：RAII 自动管理
{
    std::scoped_lock lock(mtx); // 构造即加锁，析构即解锁
    doSomething();
    if (error) return; // 安全返回，锁自动释放
}
```

**代码示例：多锁安全获取**

```cpp
// ❌ 劣质代码：死锁风险
void transfer(Account& from, Account& to, int amount) {
    std::lock_guard<std::mutex> lock1(from.mutex);
    std::lock_guard<std::mutex> lock2(to.mutex);  // 💥 另一个线程可能反向加锁
    // ...
}

// ✅ C++17 重构：std::scoped_lock 保证安全
void transfer(Account& from, Account& to, int amount) {
    std::scoped_lock lock(from.mutex, to.mutex);  // 算法保证无死锁
    from.balance -= amount;
    to.balance += amount;
}
```

**代码示例：读写锁优化**

```cpp
// ❌ 使用互斥锁保护读多写少的数据
std::mutex m_mutex;
Config m_config;

Config getConfig() {
    std::lock_guard lock(m_mutex);  // 读操作也要独占锁
    return m_config;
}

// ✅ C++17：使用 shared_mutex 提升读并发
std::shared_mutex m_mutex;
Config m_config;

Config getConfig() const {
    std::shared_lock lock(m_mutex);  // 多个读者可并发
    return m_config;
}

void setConfig(const Config& cfg) {
    std::unique_lock lock(m_mutex);  // 写者独占
    m_config = cfg;
}
```

#### 3. 接口与逻辑稳健性

**架构原则**：让编译器帮我们找 Bug。

| Bug 类型 | 传统/错误写法 | C++17 架构师修复方案 |
|---------|-------------|---------------------|
| **忽略错误** | `connect(a, sig, b, slot);` (失败无感知) | **`[[nodiscard]]`** 标记关键函数，忽略返回值编译报错 |
| **类型混淆** | `void* userData` (转换危险) | **`std::variant` / `std::any`** 类型安全的联合体 |
| **Map 遍历易错** | `it->first`, `it->second` | **Structured Binding** `for (const auto& [id, widget] : map)` |
| **错误码传递** | `bool ok; QString err;` | **`std::variant<Result, Error>`** 类型安全的结果表达 |

**代码示例：强制检查返回值**

```cpp
// ❌ 信号槽连接失败无感知
connect(sender, &Sender::signal, receiver, &Receiver::slot);
// 如果 receiver 已销毁，连接失败，但代码继续执行...

// ✅ 使用 [[nodiscard]] 或显式检查
[[nodiscard]] bool safeConnect(...);

// 调用处
bool ok = connect(sender, &Sender::signal, receiver, &Receiver::slot);
Q_ASSERT(ok);  // Debug 时断言
if (!ok) {
    qWarning() << "Signal-slot connection failed!";
}
```

**代码示例：类型安全的多态返回**

```cpp
// ❌ 使用 void* 传递用户数据
void setUserData(void* data);
void* getUserData();

// 使用时：
auto* widget = static_cast<Widget*>(getUserData());  // 💥 类型错误无法检测

// ✅ C++17：使用 std::variant 或 std::any
using UserData = std::variant<int, QString, WidgetPtr>;

void setUserData(UserData data);
UserData getUserData();

// 使用时：
auto data = getUserData();
if (auto* widget = std::get_if<WidgetPtr>(&data)) {
    // 类型安全访问
}
```

**代码示例：结构化绑定提升可读性**

```cpp
// ❌ 传统写法：可读性差
for (auto it = map.begin(); it != map.end(); ++it) {
    int id = it->first;
    Widget* widget = it->second;
    // ...
}

// ✅ C++17 结构化绑定
for (const auto& [id, widget] : map) {
    // 直接使用 id 和 widget，清晰明了
}

// 同样适用于 std::pair, std::tuple, 自定义结构体
auto [success, value, error] = parseInput(input);
if (success) {
    process(value);
} else {
    handleError(error);
}
```

---

### 第四步：防御性验证 (Sanitization)

在"修复"之后，必须通过工具链**证明**问题不存在，而非仅凭肉眼观察。

#### 4.1 静态分析 (Static Analysis)

| 工具 | 用途 | 关键检查项 |
|-----|------|-----------|
| **Clang-Tidy** | 代码规范+Bug检测 | `modernize-*`, `bugprone-*`, `cppcoreguidelines-*` |
| **Cppcheck** | 深度静态分析 | 未初始化变量、越界访问、内存泄漏 |
| **PVS-Studio** | 商业级分析 | 复杂的数据流分析 |

#### 4.2 运行时消毒 (Runtime Sanitizers)

**必须在 Debug/Test 构建中启用**

| Sanitizer | 用途 | CMake 配置 |
|-----------|------|-----------|
| **AddressSanitizer (ASan)** | 内存越界、Use-after-free、内存泄漏 | `-fsanitize=address` |
| **UndefinedBehaviorSanitizer (UBSan)** | 整数溢出、空指针解引用、对齐错误 | `-fsanitize=undefined` |
| **ThreadSanitizer (TSan)** | 数据竞争 (Data Race) | `-fsanitize=thread` |
| **MemorySanitizer (MSan)** | 未初始化内存读取 | `-fsanitize=memory` |

**CMakeLists.txt 配置示例**

```cmake
# Debug 构建启用 Sanitizers
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # AddressSanitizer + UndefinedBehaviorSanitizer
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,undefined")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")

    # 或者 ThreadSanitizer（不能与 ASan 同时使用）
    # set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=thread")
endif()
```

**注意**：ASan 和 TSan 不能同时启用，需要分别构建测试。

#### 4.3 验证清单

- [ ] ASan 检测通过（无内存泄漏、无越界访问）
- [ ] UBSan 检测通过（无未定义行为）
- [ ] TSan 检测通过（无数据竞争）— 如果涉及多线程
- [ ] 单元测试覆盖边界情况
- [ ] 压力测试通过（如果是偶发问题）

---

### 第五步：标准 Bug 报告模板

```markdown
## 缺陷修复报告 (Defect Resolution Report)

### 1. 核心诊断
- **缺陷类型**: [Lifetime / Concurrency / UB / Qt-Specific]
- **严重等级**: [Critical / Major / Minor]
- **影响范围**: [崩溃 / 数据损坏 / 功能异常 / 性能问题]

### 2. 根因分析
[详细描述问题的根本原因，而不是表面症状]

示例：
> 原代码使用了裸指针管理 `m_worker`，在 `Worker` 线程未结束时主对象析构，
> 导致悬空指针回调。违反了 RAII 原则，且未处理线程 join。

### 3. 修复方案 (C++17)

**策略**:
1. 将 `Worker*` 替换为 `std::unique_ptr<Worker>` 明确所有权
2. 引入 `std::atomic<bool>` 作为线程停止标志
3. 析构函数中强制 `if(thread.joinable()) thread.join()`

### 4. 代码对比

**Before (Risky):**
```cpp
Worker* m_worker = new Worker();
// ... 手动 delete，极易遗漏，且无线程同步
```

**After (Robust):**
```cpp
std::unique_ptr<Worker> m_worker;
std::atomic<bool> m_stopFlag{false};

~Controller() {
    m_stopFlag = true;
    if (m_thread.joinable()) {
        m_thread.join();
    }
    // m_worker 自动释放
}
```

### 5. 验证与回归

- [x] ASan 检测通过 (无内存泄漏)
- [x] TSan 检测通过 (无数据竞争)
- [x] 单元测试覆盖边界情况
- [x] 原问题不再复现
- [ ] 集成测试通过
```

---

## 常见 Bug 速查表

| 症状 | 可能原因 | 检测工具 | C++17 修复方向 |
|-----|---------|---------|---------------|
| 崩溃在 delete | 双重释放 / 野指针 | ASan | `std::unique_ptr` |
| 随机崩溃 | 悬空指针 / 数据竞争 | ASan / TSan | `QPointer` / `scoped_lock` |
| UI 卡死 | 事件循环阻塞 / 死锁 | 调试器 / TSan | `std::scoped_lock` |
| 信号无响应 | 连接失败 / 对象销毁 | 调试日志 | `QPointer` + 检查返回值 |
| 内存持续增长 | 内存泄漏 | ASan / Valgrind | RAII / 智能指针 |
| 数据损坏 | 数据竞争 | TSan | `shared_mutex` / 原子操作 |
| Debug 正常 Release 崩溃 | 未初始化变量 | MSan / UBSan | 强制初始化 |
| 返回值被忽略 | 错误未处理 | Clang-Tidy | `[[nodiscard]]` |

---

## 架构师的箴言 (Architect's Insight)

### 1. Don't just fix the crash; fix the state.

不要只是为了让程序不崩而加 `if (ptr != nullptr)`。要问自己：
- 为什么这里允许出现 `nullptr`？
- 能不能用引用？
- 能不能用 `std::optional`？

### 2. Make invalid states unrepresentable.

利用 C++ 强类型系统，让错误的代码**根本无法通过编译**。

```cpp
// ❌ 允许无效状态
struct Config {
    int port;        // 可能是 -1 表示未设置？还是 0？
    QString host;    // 空字符串表示什么？
};

// ✅ 类型系统约束
struct Config {
    Port port;                    // 强类型，构造时验证
    std::optional<QString> host;  // 明确表达"可选"
};
```

### 3. Trust the Sanitizers.

> 人眼是不可靠的，AddressSanitizer 是诚实的。
> **没有跑过 ASan 的 C++ 代码不配上线。**

---

## Qt 特定问题速查

### 信号槽跨线程

```cpp
// ❌ 危险：在工作线程直接调用 UI 方法
void Worker::onDataReady() {
    m_mainWindow->updateUI(data);  // 💥 跨线程访问 UI
}

// ✅ 安全：使用信号槽跨线程
void Worker::onDataReady() {
    emit dataReady(data);  // 信号自动排队到 UI 线程
}

// 连接时使用 QueuedConnection（跨线程时默认）
connect(worker, &Worker::dataReady,
        mainWindow, &MainWindow::updateUI,
        Qt::QueuedConnection);
```

### QObject 生命周期

```cpp
// ❌ 危险：栈上创建有父对象的 QObject
void createWidget() {
    QWidget child(&parentWidget);  // 💥 函数返回后 child 销毁
    // parentWidget 仍持有已销毁的 child 指针
}

// ✅ 安全：堆上创建，父对象管理生命周期
void createWidget() {
    auto* child = new QWidget(&parentWidget);  // parentWidget 负责 delete
}
```

### Lambda 捕获陷阱

```cpp
// ❌ 危险：lambda 捕获 this，但 this 可能先于 lambda 销毁
connect(timer, &QTimer::timeout, [this]() {
    this->doSomething();  // 💥 如果 this 已销毁
});

// ✅ 安全：使用 QPointer 或指定上下文对象
connect(timer, &QTimer::timeout, this, [this]() {
    this->doSomething();  // this (上下文对象) 销毁时连接自动断开
});
```
