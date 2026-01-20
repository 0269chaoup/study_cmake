# Step1: 基础安装 (BasicInstall)

本步骤学习 CMake 最基本的安装功能。

## 学习目标

- `install(TARGETS)` 安装可执行文件和库
- `install(FILES)` 安装头文件
- 理解 `CMAKE_INSTALL_PREFIX` 的作用
- 静态库的安装

## 关键概念

### 1. CMAKE_INSTALL_PREFIX

`CMAKE_INSTALL_PREFIX` 是安装的根目录，所有 `install()` 命令中的 `DESTINATION` 都是相对于这个路径。

```bash
# 配置时指定安装目录
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/path/to/install
```

默认值：
- Linux/macOS: `/usr/local`
- Windows: `C:/Program Files/${PROJECT_NAME}`

### 2. install(TARGETS)

安装构建目标（可执行文件、库）：

```cmake
# 安装可执行文件到 bin 目录
install(TARGETS myapp DESTINATION bin)

# 安装静态库到 lib 目录
install(TARGETS mymath ARCHIVE DESTINATION lib)
```

目标类型关键字：
- `RUNTIME` - 可执行文件（Windows 上还包括 DLL）
- `ARCHIVE` - 静态库 (.a, .lib)
- `LIBRARY` - 共享库 (.so, .dylib)

### 3. install(FILES)

安装普通文件（头文件、配置文件等）：

```cmake
# 安装头文件到 include 目录
install(FILES mymath.h DESTINATION include)
```

## 项目结构

```
Step1-BasicInstall/
├── CMakeLists.txt           # 主 CMake 配置
├── README.md                # 本文档
└── src/
    ├── main.cpp             # 主程序
    └── mymath/
        ├── CMakeLists.txt   # 库的 CMake 配置
        ├── mymath.cpp       # 库实现
        └── mymath.h         # 库头文件
```

## 构建和安装

```bash
# 1. 配置（指定安装目录为当前目录下的 install 文件夹）
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install

# 2. 构建
cmake --build build

# 3. 安装
cmake --install build

# 4. 查看安装结果
ls -la ./install/
```

## 安装后的目录结构

```
install/
├── bin/
│   └── myapp (或 myapp.exe)
├── lib/
│   └── libmymath.a (或 mymath.lib)
└── include/
    └── mymath.h
```

## 运行测试

```bash
# Linux/macOS
./install/bin/myapp 16

# Windows
.\install\bin\myapp.exe 16
```

输出：
```
The square root of 16 is 4
16 squared is 256
```

## 其他安装选项

```bash
# 仅安装指定的构建配置 (Debug/Release)
cmake --install build --config Release

# 显示详细安装信息
cmake --install build --verbose

# 使用 DESTDIR 重定向安装（用于打包）
# 最终安装到 /tmp/staging/usr/local/...
DESTDIR=/tmp/staging cmake --install build
```

## 下一步

继续学习 [Step2-GNUInstallDirs](../Step2-GNUInstallDirs/README.md)，了解如何使用标准目录变量和组件安装。
