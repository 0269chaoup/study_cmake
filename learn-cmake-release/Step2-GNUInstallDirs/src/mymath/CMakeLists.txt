# 创建静态库
add_library(mymath STATIC
    mymath.cpp
    mymath.h
)

# 设置头文件包含路径
target_include_directories(mymath
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# =============================================================================
# 使用 GNUInstallDirs 变量安装
# =============================================================================

# 安装静态库到标准 lib 目录
# COMPONENT Development 表示这是开发相关的文件
install(TARGETS mymath
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    COMPONENT Development
)

# 安装头文件到标准 include 目录
install(FILES mymath.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    COMPONENT Development
)
