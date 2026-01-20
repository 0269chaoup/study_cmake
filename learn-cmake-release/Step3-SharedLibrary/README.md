# Step3: 共享库与版本控制 (SharedLibrary)

本步骤学习如何创建和安装共享库（动态链接库）。

## 学习目标

- 使用 `BUILD_SHARED_LIBS` 选项
- 使用 `GenerateExportHeader` 生成导出宏
- 设置库的 `VERSION` 和 `SOVERSION`
- 配置 RPATH（Linux/macOS）
- 处理 Windows DLL

## 关键概念

### 1. BUILD_SHARED_LIBS 选项

```cmake
option(BUILD_SHARED_LIBS "Build using shared libraries" ON)
```

当设置为 `ON` 时，`add_library()` 不指定类型会默认创建共享库。

### 2. GenerateExportHeader 模块

Windows DLL 的符号默认是隐藏的，需要显式导出。`GenerateExportHeader` 模块自动生成跨平台的导出宏：

```cmake
include(GenerateExportHeader)

generate_export_header(mymath
    EXPORT_FILE_NAME mymath_export.h
    EXPORT_MACRO_NAME MYMATH_API
)
```

生成的 `mymath_export.h` 文件包含：
- `MYMATH_API` - 用于导出函数/类
- `MYMATH_NO_EXPORT` - 标记不导出的符号
- `MYMATH_DEPRECATED` - 标记废弃的 API

在头文件中使用：

```cpp
#include "mymath_export.h"

MYMATH_API double sqrt(double x);  // 导出此函数
```

### 3. VERSION 和 SOVERSION

```cmake
set_target_properties(mymath PROPERTIES
    VERSION ${PROJECT_VERSION}      # 完整版本: 1.0.0
    SOVERSION ${PROJECT_VERSION_MAJOR}  # API 版本: 1
)
```

在 Linux 上生成的文件和符号链接：
```
libmymath.so -> libmymath.so.1 -> libmymath.so.1.0.0
```

- `libmymath.so.1.0.0` - 实际的库文件
- `libmymath.so.1` - SONAME 符号链接（运行时链接）
- `libmymath.so` - 开发时链接

### 4. RPATH 配置

RPATH 是嵌入到可执行文件中的库搜索路径：

```cmake
if(APPLE)
    set(CMAKE_INSTALL_RPATH "@executable_path/../lib")
elseif(UNIX)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
endif()
```

- `$ORIGIN` (Linux) 和 `@executable_path` (macOS) 表示可执行文件所在目录
- `../lib` 表示相对于可执行文件目录向上一级，再进入 lib 目录

### 5. Windows DLL 安装

在 Windows 上：
- DLL 文件应安装到 `bin` 目录（与 exe 相同目录）
- 导入库 (.lib) 安装到 `lib` 目录

```cmake
install(TARGETS mymath
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}   # .dll
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}   # .so, .dylib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}   # .lib (导入库), .a
)
```

## 项目结构

```
Step3-SharedLibrary/
├── CMakeLists.txt
├── README.md
└── src/
    ├── main.cpp
    └── mymath/
        ├── CMakeLists.txt
        ├── mymath.cpp
        └── mymath.h
```

## 构建和安装

```bash
# 构建共享库版本（默认）
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
cmake --build build
cmake --install build

# 构建静态库版本
cmake -S . -B build-static -DCMAKE_INSTALL_PREFIX=./install-static -DBUILD_SHARED_LIBS=OFF
cmake --build build-static
cmake --install build-static
```

## 安装后的目录结构

### Linux/macOS（共享库）

```
install/
├── bin/
│   └── myapp
├── include/
│   ├── mymath.h
│   └── mymath_export.h
└── lib/
    ├── libmymath.so -> libmymath.so.1
    ├── libmymath.so.1 -> libmymath.so.1.0.0
    └── libmymath.so.1.0.0
```

### Windows

```
install/
├── bin/
│   ├── myapp.exe
│   └── mymath.dll
├── include/
│   ├── mymath.h
│   └── mymath_export.h
└── lib/
    └── mymath.lib  (导入库)
```

## 运行测试

```bash
# Linux/macOS - 由于设置了 RPATH，可以直接运行
./install/bin/myapp 16

# Windows
.\install\bin\myapp.exe 16
```

## 查看 RPATH（Linux）

```bash
# 使用 readelf
readelf -d ./install/bin/myapp | grep RPATH

# 使用 chrpath
chrpath -l ./install/bin/myapp
```

## 常见问题

### 1. 运行时找不到共享库

Linux 错误：`error while loading shared libraries: libmymath.so: cannot open shared object file`

解决方法：
- 确保 RPATH 设置正确
- 或者将库路径添加到 `LD_LIBRARY_PATH`

### 2. Windows DLL 找不到

确保 DLL 文件与 exe 文件在同一目录，或者在系统 PATH 中。

## 下一步

继续学习 [Step4-CPack](../Step4-CPack/README.md)，了解如何使用 CPack 打包项目。
