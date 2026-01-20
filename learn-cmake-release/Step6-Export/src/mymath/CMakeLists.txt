include(GenerateExportHeader)

# 创建库
add_library(mymath
    mymath.cpp
    mymath.h
)

# 为库创建别名目标
# 这允许在同一项目中使用 MyMath::mymath 语法
# 与 find_package 后使用的语法一致
add_library(MyMath::mymath ALIAS mymath)

# 生成导出头文件
generate_export_header(mymath
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    EXPORT_MACRO_NAME MYMATH_API
)

# 设置包含路径
# BUILD_INTERFACE: 构建时使用的路径
# INSTALL_INTERFACE: 安装后使用的路径（相对于安装前缀）
target_include_directories(mymath
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# 设置版本
set_target_properties(mymath PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# =============================================================================
# 安装和导出
# =============================================================================

# 安装库文件并导出目标
# EXPORT MyMathTargets 将此目标添加到导出集
install(TARGETS mymath
    EXPORT MyMathTargets           # 添加到导出集
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)

# 安装头文件
install(FILES
    mymath.h
    ${CMAKE_CURRENT_BINARY_DIR}/mymath_export.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)
