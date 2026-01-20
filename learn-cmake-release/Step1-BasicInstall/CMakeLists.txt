cmake_minimum_required(VERSION 3.15)

# 设置项目名称和版本
project(MyMathApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加数学库子目录
add_subdirectory(src/mymath)

# 创建可执行文件
add_executable(myapp src/main.cpp)

# 链接数学库
target_link_libraries(myapp PRIVATE mymath)

# =============================================================================
# 安装规则 (本教程的重点)
# =============================================================================

# 1. install(TARGETS) - 安装可执行文件
# DESTINATION 指定安装到 CMAKE_INSTALL_PREFIX 下的相对路径
# 可执行文件通常安装到 bin 目录
install(TARGETS myapp
    DESTINATION bin
)

# 注意：mymath 库的安装规则在 src/mymath/CMakeLists.txt 中定义

# =============================================================================
# 使用说明
# =============================================================================
#
# 构建和安装：
#   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
#   cmake --build build
#   cmake --install build
#
# CMAKE_INSTALL_PREFIX 是安装的根目录
# 默认值：
#   - Linux/macOS: /usr/local
#   - Windows: C:/Program Files/${PROJECT_NAME}
#
# 安装后的目录结构：
#   install/
#   ├── bin/
#   │   └── myapp (或 myapp.exe)
#   ├── lib/
#   │   └── libmymath.a (或 mymath.lib)
#   └── include/
#       └── mymath.h
