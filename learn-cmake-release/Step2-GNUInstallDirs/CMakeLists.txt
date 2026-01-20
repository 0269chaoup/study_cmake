cmake_minimum_required(VERSION 3.15)

# 设置项目名称和版本
project(MyMathApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# =============================================================================
# 引入 GNUInstallDirs 模块 (本步骤重点)
# =============================================================================
# 该模块定义了符合 GNU 标准的安装目录变量
include(GNUInstallDirs)

# GNUInstallDirs 定义的常用变量：
# CMAKE_INSTALL_BINDIR      - bin (可执行文件)
# CMAKE_INSTALL_LIBDIR      - lib 或 lib64 (库文件)
# CMAKE_INSTALL_INCLUDEDIR  - include (头文件)
# CMAKE_INSTALL_DATADIR     - share (数据文件)
# CMAKE_INSTALL_SYSCONFDIR  - etc (配置文件)
# CMAKE_INSTALL_DOCDIR      - share/doc/${PROJECT_NAME} (文档)

# 添加数学库子目录
add_subdirectory(src/mymath)

# 创建可执行文件
add_executable(myapp src/main.cpp)

# 链接数学库
target_link_libraries(myapp PRIVATE mymath)

# =============================================================================
# 使用 GNUInstallDirs 变量和 COMPONENT 分组安装
# =============================================================================

# 安装可执行文件到标准 bin 目录
# COMPONENT 用于分组安装，可以只安装特定组件
install(TARGETS myapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT Runtime
)

# 安装配置文件到标准 etc 目录
# RENAME 可以在安装时重命名文件
install(FILES config/app.conf
    DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/${PROJECT_NAME}
    COMPONENT Config
)

# =============================================================================
# 使用说明
# =============================================================================
#
# 构建和安装所有组件：
#   cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
#   cmake --build build
#   cmake --install build
#
# 只安装特定组件：
#   cmake --install build --component Runtime
#   cmake --install build --component Development
#   cmake --install build --component Config
#
# 安装后的目录结构：
#   install/
#   ├── bin/
#   │   └── myapp
#   ├── etc/
#   │   └── MyMathApp/
#   │       └── app.conf
#   ├── include/
#   │   └── mymath.h
#   └── lib/
#       └── libmymath.a
