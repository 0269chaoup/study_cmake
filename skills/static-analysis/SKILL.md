# 静态代码检查与修复 (Static Analysis & Fix)

这个 skill 用于执行 Qt 5.15/C++17 代码的静态检查，基于 **XRE3 项目代码质量规范**，识别潜在问题并提供自动修复方案。

## 适用场景

- 代码提交前的静态检查
- 代码审查中的问题识别
- 批量代码规范修复
- 安全漏洞检测
- 性能问题预警

---

## 检查规则体系

### 启用的 Clang-Tidy 检查类别

```yaml
Checks: >
  bugprone-*,              # 可能的编程错误
  cert-*,                  # CERT 安全编码标准
  clang-analyzer-*,        # Clang 静态分析器
  cppcoreguidelines-*,     # C++ 核心指南
  google-*,                # Google C++ 风格指南
  modernize-*,             # C++ 现代化建议
  performance-*,           # 性能优化建议
  readability-*,           # 代码可读性
```

### 禁用的规则（XRE3 特定）

```yaml
  -modernize-use-trailing-return-type,          # 不强制尾部返回类型
  -readability-magic-numbers,                   # 允许魔数（但不推荐）
  -readability-braces-around-statements,        # 不强制单行语句的花括号
  -cppcoreguidelines-avoid-magic-numbers,       # 允许魔数
  -cppcoreguidelines-pro-bounds-pointer-arithmetic,  # 允许指针算术
  -google-readability-braces-around-statements       # 不强制花括号
```

### 复杂度阈值

| 指标 | 阈值 | 说明 |
|-----|------|------|
| 函数认知复杂度 | ≤ 25 | `readability-function-cognitive-complexity` |
| 函数行数 | ≤ 80 | `readability-function-size.LineThreshold` |

---

## 命名约定检查（XRE3 标准）

### 强制命名规则

| 类型 | 规则 | 正则表达式 | 示例 |
|------|------|-----------|------|
| **成员变量** | m_ 前缀 + camelCase | `m_[a-z][a-zA-Z0-9]*` | `int m_count;` |
| **静态成员** | s_ 前缀 + camelCase | `s_[a-z][a-zA-Z0-9]*` | `static int s_timeout;` |
| **全局变量** | g_ 前缀 + camelCase | `g_[a-z][a-zA-Z0-9]*` | `int g_instance;` |
| **类/结构体** | PascalCase | `[A-Z][a-zA-Z0-9]*` | `class MyClass` |
| **公共方法** | PascalCase | `[A-Z][a-zA-Z0-9]*` | `void DoSomething();` |
| **私有方法** | camelCase | `[a-z][a-zA-Z0-9]*` | `void doInternal();` |
| **局部变量** | camelCase | `[a-z][a-zA-Z0-9]*` | `int localCounter;` |
| **宏定义** | UPPER_SNAKE_CASE | `[A-Z][A-Z0-9_]*` | `#define MAX_SIZE 100` |
| **constexpr** | snake_case | `[a-z][a-z0-9_]*` | `constexpr int max_value = 10;` |

```cpp
// ❌ 违反命名规范
class myClass {                    // 应为 PascalCase
    int count;                     // 成员变量应有 m_ 前缀
    static int timeout;            // 静态成员应有 s_ 前缀
    void DoInternal();             // 私有方法应为 camelCase
};

// ✅ 符合 XRE3 命名规范
class MyClass {
    int m_count;
    static int s_timeout;
    void doInternal();
public:
    void DoSomething();
};
```

---

## 代码格式检查（Clang-Format）

### 核心格式规则

| 设置项 | 值 | 说明 |
|--------|-----|------|
| **BasedOnStyle** | LLVM | 基于 LLVM 风格 |
| **IndentWidth** | 4 | 4 个空格缩进 |
| **UseTab** | Never | 禁止使用 Tab |
| **ColumnLimit** | 120 | 单行最大 120 字符 |
| **PointerAlignment** | Left | 指针靠左 `int* ptr` |
| **ReferenceAlignment** | Left | 引用靠左 `int& ref` |
| **BreakBeforeBraces** | Allman | 花括号独占一行 |

### Allman 花括号风格

```cpp
// ✅ Allman 风格 (XRE3 标准)
class MyClass
{
public:
    void DoSomething()
    {
        if (condition)
        {
            // ...
        }
        else
        {
            // ...
        }
    }
};

// ❌ K&R 风格 (不符合规范)
class MyClass {
public:
    void DoSomething() {
        if (condition) {
            // ...
        } else {
            // ...
        }
    }
};
```

### 其他格式规则

```yaml
SpaceAfterTemplateKeyword: true           # template <T>
SpaceBeforeAssignmentOperators: true      # x = 1
SpacesBeforeTrailingComments: 2           # code;  // comment
AlwaysBreakTemplateDeclarations: Yes      # 模板声明始终换行
BreakConstructorInitializers: BeforeColon # 初始化列表冒号前换行
BreakInheritanceList: BeforeColon         # 继承列表冒号前换行
AllowShortFunctionsOnASingleLine: Inline  # 内联函数可单行
AllowShortIfStatementsOnASingleLine: Never # if 语句禁止单行
AllowShortLoopsOnASingleLine: false       # 循环禁止单行
SortIncludes: false                       # 不自动排序 include
```

---

## 检查类别详情

### 1. 所有权与生命周期检查 (Critical)

| 检查项 | 严重级别 | 规则 ID |
|-------|---------|--------|
| 裸 new/delete | 🔴 BLOCKER | `cppcoreguidelines-owning-memory` |
| 悬空指针风险 | 🔴 BLOCKER | `bugprone-dangling-handle` |
| 智能指针误用 | 🟡 MAJOR | `bugprone-use-after-move` |
| 资源泄漏 | 🔴 CRITICAL | `clang-analyzer-cplusplus.NewDeleteLeaks` |

```cpp
// ❌ 使用裸指针
Widget* widget = new Widget();

// ✅ 使用 ObjectUniquePtr (XRE3 项目标准)
auto widget = MakeUnique<Widget>();

// ✅ 或使用 std::unique_ptr
auto widget = std::make_unique<Widget>();
```

### 2. 现代 C++ 检查 (modernize-*)

| 检查项 | 严重级别 | 规则 ID |
|-------|---------|--------|
| 使用 nullptr | 🟡 MAJOR | `modernize-use-nullptr` |
| 使用 override | 🟡 MAJOR | `modernize-use-override` |
| 使用 auto | 🔵 MINOR | `modernize-use-auto` |
| 使用范围 for | 🔵 MINOR | `modernize-loop-convert` |
| 使用 emplace | 🔵 MINOR | `modernize-use-emplace` |
| 使用 = default | 🔵 MINOR | `modernize-use-equals-default` |
| 使用 = delete | 🔵 MINOR | `modernize-use-equals-delete` |

```cpp
// ❌ 旧式 C++ 写法
class MyClass : public Base {
public:
    MyClass() {}                              // 应使用 = default
    virtual void OnEvent() {}                 // 缺少 override
    void Process(Widget* w) { if (w == NULL) {} }  // 应使用 nullptr
};
for (std::vector<int>::iterator it = v.begin(); it != v.end(); ++it) {}

// ✅ 现代 C++17 写法
class MyClass : public Base {
public:
    MyClass() = default;
    void OnEvent() override {}
    void Process(Widget* w) { if (w == nullptr) {} }
};
for (const auto& item : v) {}
```

### 3. 性能检查 (performance-*)

| 检查项 | 严重级别 | 规则 ID |
|-------|---------|--------|
| 不必要的拷贝初始化 | 🟡 MAJOR | `performance-unnecessary-copy-initialization` |
| 低效的字符串拼接 | 🟡 MAJOR | `performance-inefficient-string-concatenation` |
| 移动 const 参数 | 🟡 MAJOR | `performance-move-const-arg` |
| for 循环拷贝 | 🔵 MINOR | `performance-for-range-copy` |
| 隐式转换 | 🔵 MINOR | `performance-implicit-conversion-in-loop` |

```cpp
// ❌ 不必要的拷贝
void Process(const std::vector<Data>& input) {
    std::vector<Data> copy = input;  // 不必要的拷贝
    for (auto item : copy) {}        // 又一次拷贝
}

// ✅ 避免拷贝
void Process(const std::vector<Data>& input) {
    const auto& ref = input;         // 使用引用
    for (const auto& item : ref) {}  // 使用 const 引用
}
```

### 4. 可读性检查 (readability-*)

| 检查项 | 严重级别 | 规则 ID | 阈值 |
|-------|---------|--------|------|
| 函数认知复杂度 | 🟡 MAJOR | `readability-function-cognitive-complexity` | ≤ 25 |
| 函数长度 | 🟡 MAJOR | `readability-function-size` | ≤ 80 行 |
| 标识符命名 | 🟡 MAJOR | `readability-identifier-naming` | XRE3 规则 |
| 简化布尔表达式 | 🔵 MINOR | `readability-simplify-boolean-expr` | - |
| 冗余控制流 | 🔵 MINOR | `readability-redundant-control-flow` | - |

### 5. Bug 检测 (bugprone-*)

| 检查项 | 严重级别 | 规则 ID |
|-------|---------|--------|
| 使用后移动 | 🔴 CRITICAL | `bugprone-use-after-move` |
| 整数除零 | 🔴 CRITICAL | `bugprone-integer-division` |
| 拷贝构造函数中 init | 🔴 CRITICAL | `bugprone-copy-constructor-init` |
| 虚函数调用 | 🟡 MAJOR | `bugprone-virtual-near-miss` |
| 可疑的 sizeof | 🟡 MAJOR | `bugprone-sizeof-expression` |
| 字符串字面量比较 | 🟡 MAJOR | `bugprone-string-literal-with-embedded-nul` |

### 6. 安全检查 (cert-*, clang-analyzer-security-*)

| 检查项 | 严重级别 | 规则 ID |
|-------|---------|--------|
| 格式化字符串漏洞 | 🔴 BLOCKER | `cert-fio30-c` |
| 命令注入 | 🔴 BLOCKER | `clang-analyzer-security.insecureAPI` |
| 不安全的 API | 🔴 CRITICAL | `cert-msc30-c` |
| 随机数生成 | 🟡 MAJOR | `cert-msc32-c` |

---

## 严重级别定义

| 级别 | 标识 | 含义 | 处理要求 |
|------|------|------|---------|
| 🔴 BLOCKER | Error | 阻塞性问题，可能导致崩溃或安全漏洞 | **必须修复** |
| 🔴 CRITICAL | Error | 关键问题，影响核心功能 | **必须修复** |
| 🟡 MAJOR | Warning | 主要问题，影响代码质量 | 应当修复 |
| 🔵 MINOR | Info | 轻微问题，可优化 | 建议修复 |
| ⚪ INFO | Hint | 提示信息 | 可选 |

---

## 报告格式

```markdown
## 静态分析报告

### 摘要
- **检查文件**: X 个
- **发现问题**: Y 个
  - 🔴 BLOCKER/CRITICAL: A 个
  - 🟡 MAJOR: B 个
  - 🔵 MINOR: C 个

### 命名约定违规
| 文件:行号 | 类型 | 当前命名 | 应为 |
|----------|------|---------|------|
| src/Foo.cpp:42 | 成员变量 | `count` | `m_count` |
| src/Bar.h:15 | 类名 | `myClass` | `MyClass` |

### 问题详情

---

#### 🔴 [BLOCKER] src/MyClass.cpp:42 - 裸 new 使用

**规则**: cppcoreguidelines-owning-memory
**问题**: 使用裸 new 分配内存，所有权不明确

**当前代码**:
```cpp
Widget* widget = new Widget();
```

**修复建议**:
```cpp
auto widget = MakeUnique<Widget>();  // XRE3 项目
// 或
auto widget = std::make_unique<Widget>();
```

---

#### 🟡 [MAJOR] src/Parser.cpp:128 - 缺少 override

**规则**: modernize-use-override
**问题**: 虚函数重写未标记 override

**当前代码**:
```cpp
virtual void OnEvent() {}
```

**修复建议**:
```cpp
void OnEvent() override {}
```

---
```

---

## SonarQube 集成

### 问题分类

| SonarQube 类型 | 对应检查 |
|---------------|---------|
| BUG | bugprone-*, clang-analyzer-* |
| CODE_SMELL | readability-*, modernize-* |
| VULNERABILITY | cert-*, security-* |

### 自动修复脚本

```bash
# 自动修复 SonarQube 检测到的问题
auto-fix-sonar.sh --severity CRITICAL --type CODE_SMELL --cpp-std c++17

# 预览模式（不实际修改）
auto-fix-sonar.sh --dry-run --severity MAJOR
```

---

## 使用方式

1. **单文件检查**: `/static-analysis path/to/file.cpp`
2. **目录检查**: `/static-analysis path/to/src/`
3. **差异检查**: `/static-analysis --diff` (只检查 git/svn 变更)
4. **指定规则**: `/static-analysis --checks=bugprone-*,modernize-*`
5. **自动修复**: `/static-analysis --fix path/to/file.cpp`
6. **格式化**: `/static-analysis --format path/to/file.cpp`

---

## 提交前检查清单

提交代码前，确保：

- [ ] 代码已通过 clang-format 格式化
- [ ] 无 BLOCKER/CRITICAL 级别问题
- [ ] 命名符合 XRE3 规范（m_, s_, g_ 前缀）
- [ ] 函数复杂度 ≤ 25，行数 ≤ 80
- [ ] 无裸 new/delete，使用智能指针
- [ ] 虚函数正确使用 override
- [ ] 提交消息符合 Conventional Commits 格式

### 提交消息格式

```
<type>: <description>

# 允许的 type:
# feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, merge, init

# 示例:
feat: Add GPU particle system
fix: Update bounding box calculation
refactor: Simplify event system
```

---

## 配置文件位置

| 文件 | 用途 |
|-----|------|
| `.clang-tidy` | Clang-Tidy 规则配置 |
| `.clang-format` | 代码格式化配置 |
| `.editorconfig` | 跨编辑器配置 |
| `.pre-commit-config.yaml` | Pre-commit 钩子配置 |
| `.sonarqube/sonar-project.properties` | SonarQube 项目配置 |

---

**注意**: 此 skill 基于 XRE3.15 项目的 CodeQualityToolkit 配置，确保与项目现有规范一致。
