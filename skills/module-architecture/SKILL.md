# 模块架构设计 (Module Architecture Design)

这个 skill 用于设计 Qt 5.15/C++17 环境下的软件模块架构，遵循**笛卡尔式怀疑论**：不相信任何隐式假设，把一切约束都显式地写在代码契约里。

## 适用场景

- 新模块/功能的架构设计
- 现有模块的重构规划
- 系统分层设计
- 接口边界定义与 ABI 稳定性规划
- 所有权模型与生命周期管理

## 设计流程

### 第一阶段：问题分析与所有权定义

1. **识别核心问题** - 确定真正要解决的问题
2. **定义所有权模型 (Define Ownership Model)**
   - 每个数据结构由谁负责创建和销毁？
   - 使用 `std::unique_ptr`（独占）还是 `std::shared_ptr`（共享）？
   - 是否适合使用 `QObject` 父子树管理？
   - **原则**：在 C++ 中，比"数据类型"更重要的是"谁负责销毁内存"
3. **映射生态** - 需要与哪些外部系统/平台交互？
4. **评估风险** - 什么最可能改变或出问题？

### 第二阶段：架构设计与 ABI 策略

1. **划定黑盒边界** - 需要哪些模块？每个模块职责单一
2. **设计清晰接口** - 模块间如何通信？Input/Output only
3. **规划依赖层次** - 什么依赖什么？避免循环依赖
4. **二进制兼容策略 (ABI Strategy)**
   - 是否需要保持 ABI 稳定？（库/插件场景）
   - 是否使用 PIMPL (d-pointer) 模式？
   - **决策点**：如果现在不决定，将来修改私有成员会导致所有依赖方重新编译
5. **考虑团队结构** - 一个模块最多一个人负责

### 第三阶段：实现策略

1. **先建基础** - 平台抽象层、核心基元
2. **创建测试应用** - 简单应用验证架构
3. **增量实现** - 一次一个模块
4. **构建工具** - 调试、测试、开发辅助

### 第四阶段：未来保障

1. **可替换性设计** - 模块能否仅通过接口重写？
2. **扩展规划** - 10倍功能/用户/开发者时还能工作吗？
3. **维护考量** - 5年后谁来维护？
4. **接口文档** - 新开发者能立即贡献吗？

## 设计原则

### 物理黑盒 (Physical Black Box)

**原则**：接口头文件不应包含任何实现细节的数据成员。

**手段**：强制使用 `d-pointer` (PIMPL) 惯用法。

**收益**：
- 编译加速（修改实现不触发依赖重编译）
- ABI 稳定（二进制兼容）
- 真正的逻辑/数据分离

```cpp
// ✅ 物理黑盒 - 头文件
class ModulePrivate; // 前置声明

class Module {
public:
    Module();
    ~Module(); // 必须在 .cpp 中实现
private:
    std::unique_ptr<ModulePrivate> d;
};

// ✅ 物理黑盒 - 实现文件
class ModulePrivate {
public:
    // 所有私有数据成员都在这里
    QString internalData;
    int counter = 0;
};

Module::Module() : d(std::make_unique<ModulePrivate>()) {}
Module::~Module() = default;
```

### 依赖层次

```
Application Layer (应用层)
        ↓
    UI Layer (界面层) ← 可使用 QObject/信号槽
        ↓
  Service Layer (服务层) ← 可使用 QObject，但核心逻辑纯 C++
        ↓
   Core Layer (核心层) ← 纯 C++17，禁止依赖 QObject
        ↓
 Platform Layer (平台层)
```

### 包装外部依赖（奥卡姆剃刀原则）

**仅在外部依赖具有高波动性或不安全性时进行包装**

| 依赖类型 | 是否包装 | 理由 |
|---------|---------|------|
| `QString`, `std::vector` | ❌ 不包装 | 稳定的公理，直接使用 |
| 第三方 HTTP 库 | ✅ 包装 | 可能更换实现 |
| 操作系统特定 API | ✅ 包装 | 跨平台需求 |
| Qt 稳定 API | ❌ 不包装 | Qt 5.15 LTS 足够稳定 |
| 实验性/Beta API | ✅ 包装 | 高波动性 |

**检验标准**：这个 Wrapper 是否只是简单转发了 API 而没有增加任何逻辑价值？如果是，删除它。

## Qt/C++17 工程规范

### 信号槽的使用范围

信号槽类似于 `GOTO`，会切断代码的线性逻辑，且有运行时开销。严格限制使用范围：

| 场景 | 推荐方案 | 理由 |
|-----|---------|------|
| **模块内部** | `std::function`、Lambda、直接调用 | 编译期检查，零开销 |
| **跨模块通信** | Qt 信号槽 | 松耦合，支持多对多 |
| **跨线程通信** | Qt 信号槽 + `Qt::QueuedConnection` | 自动线程安全 |
| **核心算法层** | 纯 C++ | 禁止依赖 QObject，便于测试和移植 |

```cpp
// ❌ 滥用信号槽
class Calculator : public QObject {
    Q_OBJECT
signals:
    void resultReady(int);
public slots:
    void calculate(int a, int b) { emit resultReady(a + b); }
};

// ✅ 核心逻辑使用纯 C++
class Calculator {
public:
    [[nodiscard]] int calculate(int a, int b) const { return a + b; }
};
```

### C++17 风格接口

函数签名应诚实地反映结果，使用类型系统表达意图：

```cpp
// ❌ 旧风格 (不确定性高，副作用隐藏)
bool parseConfig(const QString& path, Config& outConfig, QString& errStr);

// ✅ 使用 std::optional 表示"可能没有结果"
[[nodiscard]] std::optional<Config> parseConfig(const QString& path);

// ✅ 使用 std::variant 表示"要么成功，要么返回错误详情"
[[nodiscard]] std::variant<Config, ErrorDetail> parseConfig(const QString& path);

// ✅ 使用 std::expected (C++23) 的 C++17 替代
template<typename T, typename E>
using Result = std::variant<T, E>;

[[nodiscard]] Result<Config, ErrorDetail> parseConfig(const QString& path);
```

### 所有权与生命周期

```cpp
// ❌ 裸指针，所有权不明确
Widget* createWidget();

// ✅ 独占所有权，调用方负责管理
[[nodiscard]] std::unique_ptr<Widget> createWidget();

// ✅ 共享所有权，引用计数管理
[[nodiscard]] std::shared_ptr<Widget> createSharedWidget();

// ✅ Qt 对象树管理，parent 负责销毁
QWidget* createWidget(QWidget* parent);
```

## 评估清单（笛卡尔式怀疑）

每个架构决策需回答：

### 基础评估
- [ ] **可替换性**: 仅通过接口能重写这个组件吗？
- [ ] **认知负载**: 一个开发者能理解并维护这个模块吗？
- [ ] **未来灵活性**: 10倍需求时还合理吗？
- [ ] **风险隔离**: 如果这里失败，会拖垮其他组件吗？
- [ ] **团队扩展**: 能否增加开发者而无需协调开销？

### 笛卡尔式拷问
- [ ] **物理隔离性**: 修改该模块的私有成员，是否需要重新编译依赖它的其他模块？（检查 PIMPL）
- [ ] **所有权清晰度**: 每个指针的生命周期是否都由智能指针或父子关系明确约束？（检查内存泄漏）
- [ ] **无谓的抽象**: 这个 Wrapper 是否只是简单转发了 API 而没有增加任何逻辑价值？（如果是，删除它）
- [ ] **线程安全性**: 如果两个线程同时调用这个接口，会发生竞态条件吗？（检查 const 和 mutex）
- [ ] **副作用透明**: 函数签名是否诚实地反映了所有可能的结果？（检查 optional/variant）

## 输出格式

架构设计应包含：

1. **架构概览图** - 使用 ASCII 或 Mermaid 图
2. **模块清单** - 每个模块的职责说明
3. **所有权模型** - 明确每个关键对象的生命周期管理方式
4. **接口规范** - 模块间的通信协议（C++17 风格）
5. **ABI 策略** - 是否使用 PIMPL，哪些接口需要稳定
6. **依赖关系** - 清晰的依赖图
7. **实现路线** - 建议的实现顺序
8. **风险评估** - 潜在问题及缓解方案

## C++ 模块头文件模板

```cpp
// UserModule.h - 接口定义
#pragma once
#include <memory>
#include <optional>
#include <functional>
#include "UserTypes.h" // 仅包含基础 POD 类型或前置声明

class UserModulePrivate; // 前置声明，隐藏实现细节

class UserModule {
public:
    // ========== 1. 显式的生命周期管理 ==========
    explicit UserModule();
    ~UserModule(); // 必须在 .cpp 中实现以支持 PIMPL

    // 禁止拷贝（独占资源）
    UserModule(const UserModule&) = delete;
    UserModule& operator=(const UserModule&) = delete;

    // 支持移动（可选）
    UserModule(UserModule&&) noexcept;
    UserModule& operator=(UserModule&&) noexcept;

    // ========== 2. C++17 风格同步接口 ==========
    // 清晰的输入(Input)和输出(Output)，无隐藏副作用
    [[nodiscard]] std::optional<DataResult> processData(const InputData& input) const;

    // 使用 variant 表达多种结果
    [[nodiscard]] std::variant<SuccessResult, ErrorDetail> executeOperation(
        std::string_view command) const;

    // ========== 3. 异步接口（如果涉及 Qt 或 I/O）==========
    // 使用回调，明确线程上下文
    void processAsync(
        const InputData& input,
        std::function<void(std::optional<DataResult>)> onFinished);

    // ========== 4. 状态查询（const 方法）==========
    [[nodiscard]] bool isValid() const noexcept;
    [[nodiscard]] std::string_view name() const noexcept;

private:
    // ========== 5. ABI 隔离 ==========
    std::unique_ptr<UserModulePrivate> d;
};
```

## 实现文件模板

```cpp
// UserModule.cpp - 实现
#include "UserModule.h"

// 私有实现类 - 所有实现细节都在这里
class UserModulePrivate {
public:
    QString internalState;
    std::vector<DataItem> cache;

    // 内部辅助方法
    void updateCache() { /* ... */ }
};

UserModule::UserModule()
    : d(std::make_unique<UserModulePrivate>())
{
}

UserModule::~UserModule() = default;

UserModule::UserModule(UserModule&&) noexcept = default;
UserModule& UserModule::operator=(UserModule&&) noexcept = default;

std::optional<DataResult> UserModule::processData(const InputData& input) const
{
    if (!isValid()) {
        return std::nullopt;
    }

    // 实现逻辑...
    return DataResult{/* ... */};
}
```

---

**核心理念**：不相信任何隐式的假设，把一切约束都显式地写在代码契约里。
