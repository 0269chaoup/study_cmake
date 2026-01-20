cmake_minimum_required(VERSION 3.15)

# 设置项目名称和版本
project(MyMathApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 引入 GNUInstallDirs
include(GNUInstallDirs)

# =============================================================================
# 共享库相关配置 (本步骤重点)
# =============================================================================

# 选项：构建共享库还是静态库
# ON = 共享库 (.so/.dylib/.dll)
# OFF = 静态库 (.a/.lib)
option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

# 控制库文件输出位置
# 这样在 Windows 上运行时可以找到 DLL
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")  # .a/.lib
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")  # .so/.dylib
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")  # .exe/.dll

# =============================================================================
# RPATH 配置 (Linux/macOS)
# =============================================================================
# RPATH 告诉可执行文件在哪里查找共享库
# 这对于不使用 LD_LIBRARY_PATH 运行程序非常重要

if(APPLE)
    # macOS: 使用 @executable_path 相对路径
    # @executable_path/../lib 表示可执行文件上一级目录的 lib 文件夹
    set(CMAKE_INSTALL_RPATH "@executable_path/../lib")
elseif(UNIX)
    # Linux: 使用 $ORIGIN 相对路径
    # $ORIGIN/../lib 表示可执行文件上一级目录的 lib 文件夹
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
endif()

# 不使用构建时的 RPATH 作为安装时的 RPATH
set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)

# 安装时设置 RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# 添加数学库子目录
add_subdirectory(src/mymath)

# 创建可执行文件
add_executable(myapp src/main.cpp)

# 链接数学库
target_link_libraries(myapp PRIVATE mymath)

# =============================================================================
# 安装规则
# =============================================================================

# 安装可执行文件
install(TARGETS myapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT Runtime
)

# =============================================================================
# 使用说明
# =============================================================================
#
# 构建共享库版本（默认）：
#   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
#   cmake --build build
#   cmake --install build
#
# 构建静态库版本：
#   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install -DBUILD_SHARED_LIBS=OFF
#   cmake --build build
#   cmake --install build
#
# 安装后的目录结构（共享库）：
#   install/
#   ├── bin/
#   │   └── myapp (或 myapp.exe + mymath.dll)
#   ├── include/
#   │   ├── mymath.h
#   │   └── mymath_export.h
#   └── lib/
#       └── libmymath.so.1.0.0 (符号链接: libmymath.so.1 -> libmymath.so)
