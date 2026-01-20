cmake_minimum_required(VERSION 3.15)

# 设置项目名称和版本
project(MyMathApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 引入 GNUInstallDirs
include(GNUInstallDirs)

# 共享库选项
option(BUILD_SHARED_LIBS "Build using shared libraries" ON)

# 库输出目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}")

# RPATH 配置
if(APPLE)
    set(CMAKE_INSTALL_RPATH "@executable_path/../lib")
elseif(UNIX)
    set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
endif()

# 添加数学库子目录
add_subdirectory(src/mymath)

# 创建可执行文件
add_executable(myapp src/main.cpp)
target_link_libraries(myapp PRIVATE mymath)

# 安装可执行文件
install(TARGETS myapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT Runtime
)

# =============================================================================
# CPack 配置 (本步骤重点)
# =============================================================================

# 引入模块，自动包含 VC++ 运行时库（Windows）
include(InstallRequiredSystemLibraries)

# 引入 CPack 配置文件
include(cmake/CPackConfig.cmake)
