# 创建静态库
add_library(mymath STATIC
    mymath.cpp
    mymath.h
)

# 设置头文件包含路径
# PUBLIC: 使用此库的目标也会获得这个包含路径
target_include_directories(mymath
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/..
)

# =============================================================================
# 安装规则
# =============================================================================

# 1. 安装静态库
# ARCHIVE 指定静态库的安装位置
# 静态库通常安装到 lib 目录
install(TARGETS mymath
    ARCHIVE DESTINATION lib
)

# 2. install(FILES) - 安装头文件
# 头文件通常安装到 include 目录
install(FILES mymath.h
    DESTINATION include
)

# =============================================================================
# install(TARGETS) 的目标类型说明：
# =============================================================================
#
# RUNTIME - 可执行文件 (Windows 上的 .exe 和 .dll)
# ARCHIVE - 静态库 (.a, .lib)
# LIBRARY - 共享库 (.so, .dylib，但不包括 Windows DLL)
#
# 可以同时指定多个类型：
# install(TARGETS mylib
#     RUNTIME DESTINATION bin
#     ARCHIVE DESTINATION lib
#     LIBRARY DESTINATION lib
# )
