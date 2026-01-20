# Consumer Project

这是一个演示如何使用 `find_package()` 来使用 MyMath 库的示例项目。

## 前提条件

首先需要构建并安装 Step6-Export：

```bash
cd ../Step6-Export
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
cmake --build build
cmake --install build
```

## 构建本项目

### 方法 1: 使用 MyMath_DIR

```bash
cmake -S . -B build -DMyMath_DIR=../Step6-Export/install/lib/cmake/MyMath
cmake --build build
```

### 方法 2: 使用 CMAKE_PREFIX_PATH

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=../Step6-Export/install
cmake --build build
```

### 方法 3: 系统安装

如果 MyMath 安装到系统默认位置（如 `/usr/local`），则无需指定路径：

```bash
cmake -S . -B build
cmake --build build
```

## 运行

```bash
# Linux/macOS
./build/consumer 16

# Windows
.\build\Debug\consumer.exe 16
```

预期输出：
```
==================================
Consumer App using MyMath Library
==================================

Input: 16
Square root: 4
Square: 256

MyMath library is working correctly!
```

## CMakeLists.txt 说明

```cmake
# 查找 MyMath 库，要求版本 >= 1.0
find_package(MyMath 1.0 REQUIRED)

# 创建可执行文件
add_executable(consumer src/main.cpp)

# 链接 MyMath 库
# 使用命名空间目标 MyMath::mymath
target_link_libraries(consumer PRIVATE MyMath::mymath)
```

使用 `find_package()` 后：
- `MyMath::mymath` 目标可用
- 包含路径自动设置
- 链接库自动处理
- 传递依赖自动处理

## find_package 搜索顺序

1. `<PackageName>_DIR` 缓存变量
2. `CMAKE_PREFIX_PATH` 列表中的路径
3. 环境变量 `<PackageName>_DIR`
4. 环境变量 `CMAKE_PREFIX_PATH`
5. 系统路径：
   - Linux: `/usr`, `/usr/local`, `/opt`
   - Windows: `C:/Program Files/*`
   - macOS: `/usr/local`, `/opt/homebrew`

## 常见问题

### 1. 找不到 MyMath

错误信息：
```
CMake Error at CMakeLists.txt:XX (find_package):
  Could not find a package configuration file provided by "MyMath"
```

解决方法：
- 确保 Step6-Export 已正确安装
- 检查 `MyMath_DIR` 路径是否正确
- 检查安装目录下是否存在 `lib/cmake/MyMath/MyMathConfig.cmake`

### 2. 版本不兼容

错误信息：
```
CMake Error: ... requested version "1.0" but found version "0.9"
```

解决方法：
- 安装兼容版本的 MyMath 库

### 3. 运行时找不到共享库

Linux：
```bash
export LD_LIBRARY_PATH=../Step6-Export/install/lib:$LD_LIBRARY_PATH
```

Windows：
- 确保 DLL 文件在 PATH 中
- 或者将 DLL 复制到可执行文件同目录

## 项目结构

```
consumer-project/
├── CMakeLists.txt
├── README.md
└── src/
    └── main.cpp
```
