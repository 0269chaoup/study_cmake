# Step5: Windows NSIS 安装包

本步骤学习使用 NSIS 创建 Windows 安装程序。

## 学习目标

- NSIS 安装包配置
- 自定义安装界面图标
- 创建开始菜单/桌面快捷方式
- 添加到系统 PATH
- 配置卸载程序

## 前提条件

需要安装 NSIS (Nullsoft Scriptable Install System)：

1. 下载：https://nsis.sourceforge.io/Download
2. 安装后确保 `makensis.exe` 在系统 PATH 中
3. 验证：`makensis /VERSION`

## 关键概念

### 1. NSIS 生成器配置

```cmake
# 使用 NSIS 生成器
set(CPACK_GENERATOR "NSIS")
```

### 2. 安装程序图标

```cmake
# 安装程序图标
set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/packaging/icon.ico")

# 卸载程序图标
set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_SOURCE_DIR}/packaging/icon.ico")
```

图片规格：
- 图标：.ico 格式，包含多种尺寸 (16x16, 32x32, 48x48, 256x256)
- 头部图片：150x57 像素 BMP
- 欢迎页面图片：164x314 像素 BMP

### 3. 安装目录

```cmake
# 安装到 Program Files\MyMathApp
set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "MyMathApp")
```

### 4. 开始菜单快捷方式

```cmake
# 创建开始菜单项
set(CPACK_NSIS_MENU_LINKS
    "bin/myapp.exe" "MyMath App"
    "doc/readme.html" "Documentation"
)
```

### 5. 桌面快捷方式

```cmake
# 创建桌面快捷方式
set(CPACK_NSIS_CREATE_ICONS_EXTRA
    "CreateShortCut '$DESKTOP\\\\MyMath App.lnk' '$INSTDIR\\\\bin\\\\myapp.exe'"
)

# 卸载时删除快捷方式
set(CPACK_NSIS_DELETE_ICONS_EXTRA
    "Delete '$DESKTOP\\\\MyMath App.lnk'"
)
```

### 6. 添加到系统 PATH

```cmake
# 将 bin 目录添加到系统 PATH
set(CPACK_NSIS_MODIFY_PATH ON)
```

这会在安装时添加路径，卸载时自动移除。

### 7. 卸载程序配置

```cmake
# 显示名称（控制面板中显示）
set(CPACK_NSIS_DISPLAY_NAME "MyMathApp 1.0.0")

# 联系方式
set(CPACK_NSIS_CONTACT "developer@example.com")

# 支持链接
set(CPACK_NSIS_HELP_LINK "https://example.com/help")
set(CPACK_NSIS_URL_INFO_ABOUT "https://example.com/about")
```

## 项目结构

```
Step5-NSIS/
├── CMakeLists.txt
├── README.md
├── cmake/
│   └── CPackConfig.cmake
├── packaging/
│   ├── License.txt
│   ├── Description.txt
│   ├── Welcome.txt
│   └── icon.ico            # 应用程序图标
└── src/
    ├── main.cpp
    └── mymath/
        ├── CMakeLists.txt
        ├── mymath.cpp
        └── mymath.h
```

## 构建和打包

```bash
# 配置（使用 Visual Studio 或 MinGW）
cmake -S . -B build -G "Visual Studio 17 2022" -A x64

# 或使用 Ninja
cmake -S . -B build -G Ninja

# 构建 Release 版本
cmake --build build --config Release

# 生成 NSIS 安装程序
cd build
cpack -G NSIS -C Release
```

## 生成的安装程序

```
MyMathApp-1.0.0-win64-setup.exe
```

## NSIS 变量参考

| 变量 | 说明 |
|------|------|
| `CPACK_NSIS_MUI_ICON` | 安装程序图标 |
| `CPACK_NSIS_MUI_UNIICON` | 卸载程序图标 |
| `CPACK_NSIS_INSTALL_ROOT` | 安装根目录 |
| `CPACK_NSIS_PACKAGE_NAME` | 开始菜单文件夹名 |
| `CPACK_NSIS_MENU_LINKS` | 开始菜单链接 |
| `CPACK_NSIS_CREATE_ICONS_EXTRA` | 额外的快捷方式创建脚本 |
| `CPACK_NSIS_DELETE_ICONS_EXTRA` | 额外的快捷方式删除脚本 |
| `CPACK_NSIS_MODIFY_PATH` | 是否修改系统 PATH |
| `CPACK_NSIS_DISPLAY_NAME` | 控制面板显示名 |
| `CPACK_NSIS_CONTACT` | 联系方式 |
| `CPACK_NSIS_HELP_LINK` | 帮助链接 |
| `CPACK_NSIS_EXECUTABLES_DIRECTORY` | 可执行文件目录 |

## 自定义 NSIS 脚本

可以使用 `CPACK_NSIS_EXTRA_*` 变量添加自定义 NSIS 脚本：

```cmake
# 安装前执行
set(CPACK_NSIS_EXTRA_PREINSTALL_COMMANDS "
    ; 检查是否已安装旧版本
    ReadRegStr $0 HKLM 'Software\\\\MyMathApp' 'InstallPath'
")

# 安装后执行
set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
    ; 注册文件类型关联
    WriteRegStr HKCR '.mymath' '' 'MyMathApp.Document'
")

# 卸载前执行
set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "
    ; 删除注册表项
    DeleteRegKey HKCR '.mymath'
")
```

## 创建图标文件

如果没有图标文件，可以：

1. 使用在线工具将 PNG 转换为 ICO
2. 使用 ImageMagick: `convert icon.png -define icon:auto-resize=256,128,64,48,32,16 icon.ico`
3. 使用 Visual Studio 的图像编辑器

## 常见问题

### 1. makensis 未找到

确保 NSIS 已安装并且 `makensis.exe` 在系统 PATH 中。

### 2. 图标不显示

- 确保 .ico 文件格式正确
- 检查路径是否正确

### 3. PATH 修改不生效

需要重启命令行窗口或注销重新登录。

## 下一步

继续学习 [Step6-Export](../Step6-Export/README.md)，了解如何导出库供其他项目使用。
