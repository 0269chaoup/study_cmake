# Step6: 库导出与 find_package 支持

本步骤学习如何导出库，使其他 CMake 项目能通过 `find_package()` 使用。

## 学习目标

- 使用 `install(EXPORT)` 导出目标
- 使用 `configure_package_config_file()` 生成 Config.cmake
- 使用 `write_basic_package_version_file()` 生成版本文件
- 使用 `NAMESPACE` 创建命名空间别名
- 让其他项目通过 `find_package()` 使用库

## 关键概念

### 1. 导出集 (Export Set)

导出集是一组要导出的目标。使用 `install(TARGETS ... EXPORT)` 将目标添加到导出集：

```cmake
install(TARGETS mymath
    EXPORT MyMathTargets           # 添加到名为 MyMathTargets 的导出集
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
```

### 2. 安装导出文件

```cmake
install(EXPORT MyMathTargets
    FILE MyMathTargets.cmake       # 生成的文件名
    NAMESPACE MyMath::             # 命名空间前缀
    DESTINATION lib/cmake/MyMath   # 安装位置
)
```

生成的 `MyMathTargets.cmake` 包含：
- 导入目标 `MyMath::mymath`
- 目标的属性（包含路径、链接库等）

### 3. Config.cmake 模板

创建 `cmake/MyMathConfig.cmake.in`：

```cmake
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/MyMathTargets.cmake")

check_required_components(MyMath)
```

使用 `configure_package_config_file()` 生成：

```cmake
configure_package_config_file(
    cmake/MyMathConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyMath
)
```

### 4. 版本文件

```cmake
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
```

版本兼容性选项：
- `AnyNewerVersion` - 任何更新版本都兼容
- `SameMajorVersion` - 主版本号相同即兼容
- `SameMinorVersion` - 主次版本号相同即兼容
- `ExactVersion` - 必须完全匹配

### 5. NAMESPACE 命名空间

使用 `NAMESPACE MyMath::` 后，导入的目标名为 `MyMath::mymath`。

好处：
- 清晰标识目标来源
- 避免名称冲突
- 如果目标不存在会报错（而不是静默忽略）

在自己项目中也使用相同名称：

```cmake
# 创建别名，使项目内外使用方式一致
add_library(MyMath::mymath ALIAS mymath)
```

### 6. BUILD_INTERFACE 和 INSTALL_INTERFACE

生成器表达式用于区分构建时和安装后的路径：

```cmake
target_include_directories(mymath
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>  # 构建时
        $<INSTALL_INTERFACE:include>                       # 安装后
)
```

## 项目结构

```
Step6-Export/
├── CMakeLists.txt
├── README.md
├── cmake/
│   ├── MyMathConfig.cmake.in   # Config 模板
│   └── CPackConfig.cmake
├── packaging/
│   └── License.txt
└── src/
    ├── main.cpp
    └── mymath/
        ├── CMakeLists.txt
        ├── mymath.cpp
        └── mymath.h
```

## 安装后的 CMake 配置文件

```
install/
└── lib/
    └── cmake/
        └── MyMath/
            ├── MyMathConfig.cmake         # find_package 入口
            ├── MyMathConfigVersion.cmake  # 版本检查
            └── MyMathTargets.cmake        # 导入目标定义
```

## 构建和安装

```bash
# 配置
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install

# 构建
cmake --build build

# 安装
cmake --install build
```

## 在其他项目中使用

消费者项目的 CMakeLists.txt：

```cmake
cmake_minimum_required(VERSION 3.15)
project(Consumer)

# 找到 MyMath 库
find_package(MyMath 1.0 REQUIRED)

add_executable(consumer main.cpp)

# 使用命名空间目标
target_link_libraries(consumer PRIVATE MyMath::mymath)
```

配置时指定路径：

```bash
cmake -S . -B build -DMyMath_DIR=/path/to/install/lib/cmake/MyMath
```

## find_package 搜索路径

`find_package(MyMath)` 会在以下位置搜索：

1. `MyMath_DIR` 变量指定的路径
2. `CMAKE_PREFIX_PATH` 中的路径
3. 系统默认路径：
   - Linux: `/usr/local/lib/cmake`
   - Windows: `C:/Program Files/MyMath/lib/cmake`

## 完整的导出流程

1. **定义库** - `add_library(mymath ...)`
2. **设置属性** - 包含路径、链接依赖等
3. **创建别名** - `add_library(MyMath::mymath ALIAS mymath)`
4. **安装目标** - `install(TARGETS mymath EXPORT MyMathTargets ...)`
5. **安装导出** - `install(EXPORT MyMathTargets ...)`
6. **创建 Config** - `configure_package_config_file(...)`
7. **创建版本** - `write_basic_package_version_file(...)`
8. **安装配置文件** - `install(FILES ...Config.cmake ...)`

## 验证

使用 `consumer-project` 目录中的示例项目验证：

```bash
# 先安装 Step6-Export
cd Step6-Export
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
cmake --build build
cmake --install build

# 然后构建消费者项目
cd ../consumer-project
cmake -S . -B build -DMyMath_DIR=../Step6-Export/install/lib/cmake/MyMath
cmake --build build

# 运行
./build/consumer 16
```

## 下一步

查看 [consumer-project](../consumer-project/README.md)，了解如何使用导出的库。
