# =============================================================================
# CPack 基础配置
# =============================================================================

set(CPACK_PACKAGE_NAME "MyMathApp")
set(CPACK_PACKAGE_VENDOR "MyCompany")
set(CPACK_PACKAGE_CONTACT "developer@example.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A simple math application")

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")

# 资源文件
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/License.txt")
set(CPACK_RESOURCE_FILE_WELCOME "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Welcome.txt")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/Description.txt")

# =============================================================================
# NSIS 特定配置 (Windows 安装程序)
# =============================================================================

if(WIN32)
    # 默认使用 NSIS 生成器
    set(CPACK_GENERATOR "NSIS")

    # -----------------------------------------------------------------
    # 安装程序名称和图标
    # -----------------------------------------------------------------

    # 安装程序文件名
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-win64-setup")

    # 安装程序图标（显示在安装程序 .exe 文件上）
    set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/packaging/icon.ico")

    # 卸载程序图标
    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_SOURCE_DIR}/packaging/icon.ico")

    # 安装程序内的页眉图片（150x57 像素）
    # set(CPACK_NSIS_MUI_HEADERIMAGE "${CMAKE_CURRENT_SOURCE_DIR}/packaging/header.bmp")

    # 安装程序欢迎/完成页面的侧边图片（164x314 像素）
    # set(CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP "${CMAKE_CURRENT_SOURCE_DIR}/packaging/welcome.bmp")

    # -----------------------------------------------------------------
    # 安装目录
    # -----------------------------------------------------------------

    # 默认安装目录（在 Program Files 下）
    set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")

    # 安装目录名称
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}")

    # -----------------------------------------------------------------
    # 开始菜单快捷方式
    # -----------------------------------------------------------------

    # 开始菜单文件夹名称
    set(CPACK_NSIS_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")

    # 创建开始菜单快捷方式
    # 格式: "可执行文件名" "快捷方式名称"
    set(CPACK_NSIS_MENU_LINKS
        "bin/myapp.exe" "MyMath App"
    )

    # 创建桌面快捷方式
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
        "CreateShortCut '$DESKTOP\\\\MyMath App.lnk' '$INSTDIR\\\\bin\\\\myapp.exe'"
    )

    # 卸载时删除桌面快捷方式
    set(CPACK_NSIS_DELETE_ICONS_EXTRA
        "Delete '$DESKTOP\\\\MyMath App.lnk'"
    )

    # -----------------------------------------------------------------
    # 系统 PATH
    # -----------------------------------------------------------------

    # 将 bin 目录添加到系统 PATH
    set(CPACK_NSIS_MODIFY_PATH ON)

    # -----------------------------------------------------------------
    # 卸载程序
    # -----------------------------------------------------------------

    # 在开始菜单中添加卸载快捷方式
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)

    # 卸载程序显示名称（在控制面板中）
    set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_NAME} ${CPACK_PACKAGE_VERSION}")

    # 联系方式 URL（显示在控制面板）
    set(CPACK_NSIS_CONTACT "${CPACK_PACKAGE_CONTACT}")

    # 帮助 URL
    set(CPACK_NSIS_HELP_LINK "https://github.com/mycompany/mymathapp")

    # 关于 URL
    set(CPACK_NSIS_URL_INFO_ABOUT "https://github.com/mycompany/mymathapp")

    # -----------------------------------------------------------------
    # 其他选项
    # -----------------------------------------------------------------

    # 请求管理员权限
    set(CPACK_NSIS_EXECUTABLES_DIRECTORY "bin")

    # 允许用户选择安装目录
    # set(CPACK_NSIS_IGNORE_LICENSE_PAGE OFF)

else()
    # 非 Windows 平台使用 TGZ
    set(CPACK_GENERATOR "TGZ")
endif()

# =============================================================================
# 组件配置
# =============================================================================

set(CPACK_COMPONENTS_ALL Runtime Development)
set(CPACK_COMPONENT_RUNTIME_DISPLAY_NAME "Application")
set(CPACK_COMPONENT_DEVELOPMENT_DISPLAY_NAME "Development Files")

# =============================================================================
# 引入 CPack
# =============================================================================
include(CPack)
