# Step2: GNUInstallDirs 标准目录

本步骤学习使用 GNUInstallDirs 模块和组件安装。

## 学习目标

- 使用 `include(GNUInstallDirs)` 模块
- 理解标准目录变量
- 使用 `COMPONENT` 进行分组安装
- 安装配置文件

## 关键概念

### 1. GNUInstallDirs 模块

```cmake
include(GNUInstallDirs)
```

这个模块定义了符合 GNU Coding Standards 的安装目录变量，使你的项目更具可移植性。

### 2. 标准目录变量

| 变量 | 默认值 | 用途 |
|------|--------|------|
| `CMAKE_INSTALL_BINDIR` | bin | 可执行文件 |
| `CMAKE_INSTALL_LIBDIR` | lib 或 lib64 | 库文件 |
| `CMAKE_INSTALL_INCLUDEDIR` | include | 头文件 |
| `CMAKE_INSTALL_DATADIR` | share | 只读数据 |
| `CMAKE_INSTALL_SYSCONFDIR` | etc | 配置文件 |
| `CMAKE_INSTALL_DOCDIR` | share/doc/${PROJECT_NAME} | 文档 |
| `CMAKE_INSTALL_MANDIR` | share/man | man 手册 |

在 64 位系统上，`CMAKE_INSTALL_LIBDIR` 可能是 `lib64`，这就是使用这些变量而不是硬编码 "lib" 的原因。

### 3. COMPONENT 分组安装

使用 `COMPONENT` 关键字将安装内容分组：

```cmake
# 运行时组件
install(TARGETS myapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT Runtime
)

# 开发组件
install(FILES mymath.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)

# 配置组件
install(FILES app.conf
    DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/${PROJECT_NAME}
    COMPONENT Config
)
```

常见的组件分类：
- **Runtime** - 运行程序所需的文件（可执行文件、共享库）
- **Development** - 开发所需的文件（头文件、静态库、cmake 配置）
- **Documentation** - 文档文件
- **Config** - 配置文件

### 4. 安装配置文件

```cmake
# 安装到 etc/MyMathApp/app.conf
install(FILES config/app.conf
    DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/${PROJECT_NAME}
    COMPONENT Config
)
```

## 项目结构

```
Step2-GNUInstallDirs/
├── CMakeLists.txt
├── README.md
├── config/
│   └── app.conf             # 配置文件
└── src/
    ├── main.cpp
    └── mymath/
        ├── CMakeLists.txt
        ├── mymath.cpp
        └── mymath.h
```

## 构建和安装

```bash
# 配置
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install

# 构建
cmake --build build

# 安装所有组件
cmake --install build
```

## 按组件安装

```bash
# 只安装运行时组件（可执行文件）
cmake --install build --component Runtime

# 只安装开发组件（库和头文件）
cmake --install build --component Development

# 只安装配置文件
cmake --install build --component Config
```

## 安装后的目录结构

```
install/
├── bin/
│   └── myapp
├── etc/
│   └── MyMathApp/
│       └── app.conf
├── include/
│   └── mymath.h
└── lib/
    └── libmymath.a
```

## 列出所有组件

在构建目录中，可以查看 `install_manifest.txt` 了解会安装哪些文件。

## 下一步

继续学习 [Step3-SharedLibrary](../Step3-SharedLibrary/README.md)，了解如何创建和安装共享库。
