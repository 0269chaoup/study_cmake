# 引入 GenerateExportHeader 模块
# 用于生成跨平台的导出宏
include(GenerateExportHeader)

# 创建库（类型由 BUILD_SHARED_LIBS 决定）
add_library(mymath
    mymath.cpp
    mymath.h
)

# =============================================================================
# 生成导出头文件 (Windows DLL 需要)
# =============================================================================
# Windows 上，DLL 的符号默认是隐藏的
# 需要使用 __declspec(dllexport) 导出符号
# 使用 GenerateExportHeader 可以自动处理跨平台问题

generate_export_header(mymath
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    EXPORT_MACRO_NAME MYMATH_API
)

# 添加生成的导出头文件的目录到包含路径
target_include_directories(mymath
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# =============================================================================
# 设置共享库版本
# =============================================================================
# VERSION: 完整版本号 (1.0.0)
# SOVERSION: API 版本号 (1)
#
# Linux 上会创建：
#   libmymath.so -> libmymath.so.1 -> libmymath.so.1.0.0
#
# macOS 上会创建：
#   libmymath.dylib -> libmymath.1.dylib -> libmymath.1.0.0.dylib

set_target_properties(mymath PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# =============================================================================
# 设置 Windows DLL 导出
# =============================================================================
# 在 Windows 上，需要设置 WINDOWS_EXPORT_ALL_SYMBOLS
# 或者使用 generate_export_header 生成的宏

# 方法1：自动导出所有符号（简单但不推荐用于大型项目）
# set_target_properties(mymath PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

# 方法2：使用 generate_export_header（推荐）
# 在头文件中使用 MYMATH_API 宏修饰要导出的函数

# =============================================================================
# 安装规则
# =============================================================================

# 安装库文件
# RUNTIME - Windows DLL (.dll)
# LIBRARY - 共享库 (.so, .dylib)
# ARCHIVE - 静态库和 Windows 导入库 (.lib, .a)
install(TARGETS mymath
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}   # .dll
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}   # .so, .dylib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}   # .a, .lib
    COMPONENT Development
)

# 安装头文件
install(FILES
    mymath.h
    ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)
