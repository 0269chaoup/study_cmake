cmake_minimum_required(VERSION 3.15)

project(Consumer VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# =============================================================================
# 使用 find_package 找到 MyMath 库
# =============================================================================
#
# find_package 会搜索以下位置：
# 1. MyMath_DIR 变量指定的路径
# 2. CMAKE_PREFIX_PATH 中的路径
# 3. 系统默认路径
#
# 配置时可以指定路径：
#   cmake -S . -B build -DMyMath_DIR=/path/to/MyMath/lib/cmake/MyMath
# 或者：
#   cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/install
# =============================================================================

# 查找 MyMath 库
# REQUIRED: 如果找不到则报错
# 1.0: 要求版本 >= 1.0（根据 MyMathConfigVersion.cmake 中的兼容性设置）
find_package(MyMath 1.0 REQUIRED)

# 如果成功找到，会定义以下变量：
#   MyMath_FOUND - TRUE
#   MyMath_VERSION - 库的版本
# 以及导入目标：
#   MyMath::mymath - 可以直接用于 target_link_libraries

# 打印找到的信息
message(STATUS "Found MyMath version: ${MyMath_VERSION}")

# =============================================================================
# 创建可执行文件
# =============================================================================

add_executable(consumer src/main.cpp)

# 链接 MyMath 库
# 使用命名空间目标 MyMath::mymath
# 这会自动处理：
# - 头文件包含路径
# - 链接库
# - 编译选项
# - 传递依赖
target_link_libraries(consumer PRIVATE MyMath::mymath)

# =============================================================================
# 使用说明
# =============================================================================
#
# 首先安装 Step6-Export：
#   cd ../Step6-Export
#   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
#   cmake --build build
#   cmake --install build
#
# 然后构建本项目：
#   cd ../consumer-project
#
#   方法1: 使用 MyMath_DIR
#   cmake -S . -B build -DMyMath_DIR=../Step6-Export/install/lib/cmake/MyMath
#
#   方法2: 使用 CMAKE_PREFIX_PATH
#   cmake -S . -B build -DCMAKE_PREFIX_PATH=../Step6-Export/install
#
#   cmake --build build
#
# 运行：
#   ./build/consumer 16      # Linux/macOS
#   .\build\Debug\consumer.exe 16  # Windows
