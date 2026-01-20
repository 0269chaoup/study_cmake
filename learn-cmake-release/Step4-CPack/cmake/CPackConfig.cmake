# =============================================================================
# CPack 基础配置
# =============================================================================

# 包的基本信息
set(CPACK_PACKAGE_NAME "MyMathApp")
set(CPACK_PACKAGE_VENDOR "MyCompany")
set(CPACK_PACKAGE_CONTACT "developer@example.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A simple math application")
set(CPACK_PACKAGE_DESCRIPTION "MyMathApp is a simple application that demonstrates CMake install and packaging. It provides basic mathematical operations like square root and squaring numbers.")

# 版本信息（自动从 project() 获取）
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")

# 包的文件名（不含扩展名）
# 默认: ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_NAME}")

# =============================================================================
# 资源文件
# =============================================================================

# 许可证文件（安装程序中显示）
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/License.txt")

# 欢迎页面（用于图形安装程序）
set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Welcome.txt")

# 描述文件
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Description.txt")

# =============================================================================
# 生成器配置
# =============================================================================

# 默认生成器（可以在命令行用 -G 覆盖）
# 常用生成器:
#   - ZIP: 跨平台 ZIP 压缩包
#   - TGZ: tar.gz 压缩包
#   - TBZ2: tar.bz2 压缩包
#   - NSIS: Windows 安装程序
#   - DEB: Debian/Ubuntu .deb 包
#   - RPM: RedHat/CentOS .rpm 包
if(WIN32)
    set(CPACK_GENERATOR "ZIP")
else()
    set(CPACK_GENERATOR "TGZ")
endif()

# =============================================================================
# 源码包配置
# =============================================================================

# 源码包生成器
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")

# 源码包文件名
set(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-source")

# 源码包排除的文件和目录
set(CPACK_SOURCE_IGNORE_FILES
    "/build/"
    "/install/"
    "/\\\\.git/"
    "/\\\\.vscode/"
    "/\\\\.idea/"
    "\\\\.gitignore"
    ".*~$"
)

# =============================================================================
# 组件配置
# =============================================================================

# 启用组件安装
set(CPACK_COMPONENTS_ALL Runtime Development)

# 组件显示名称
set(CPACK_COMPONENT_RUNTIME_DISPLAY_NAME "Application")
set(CPACK_COMPONENT_DEVELOPMENT_DISPLAY_NAME "Development Files")

# 组件描述
set(CPACK_COMPONENT_RUNTIME_DESCRIPTION "The main application executable and required libraries")
set(CPACK_COMPONENT_DEVELOPMENT_DESCRIPTION "Header files and static libraries for development")

# 组件依赖关系
# Development 组件依赖 Runtime 组件
set(CPACK_COMPONENT_DEVELOPMENT_DEPENDS Runtime)

# 组件分组
set(CPACK_COMPONENT_RUNTIME_GROUP "Core")
set(CPACK_COMPONENT_DEVELOPMENT_GROUP "Development")

# =============================================================================
# 引入 CPack（必须在所有 CPACK_* 变量设置之后）
# =============================================================================
include(CPack)
