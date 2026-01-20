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
target_link_libraries(myapp PRIVATE MyMath::mymath)

# 安装可执行文件
install(TARGETS myapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT Runtime
)

# =============================================================================
# 导出配置 (本步骤重点)
# =============================================================================

# 引入 CMakePackageConfigHelpers 模块
include(CMakePackageConfigHelpers)

# 生成 Config.cmake 文件
# 这个文件允许其他项目通过 find_package(MyMath) 找到我们的库
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/MyMathConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath
)

# 生成版本文件
# 这允许 find_package(MyMath 1.0) 检查版本兼容性
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# 安装 Config.cmake 和 ConfigVersion.cmake
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyMathConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath
    COMPONENT Development
)

# 安装导出目标文件
# 这是由 install(TARGETS ... EXPORT) 生成的
install(EXPORT MyMathTargets
    FILE MyMathTargets.cmake
    NAMESPACE MyMath::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MyMath
    COMPONENT Development
)

# 为构建树生成导出文件（可选，用于 build 目录内的 find_package）
export(EXPORT MyMathTargets
    FILE ${CMAKE_CURRENT_BINARY_DIR}/MyMathTargets.cmake
    NAMESPACE MyMath::
)

# =============================================================================
# CPack 配置
# =============================================================================

include(InstallRequiredSystemLibraries)
include(cmake/CPackConfig.cmake)
