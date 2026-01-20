# Step4: CPack 基础打包

本步骤学习使用 CPack 创建软件包。

## 学习目标

- CPack 基础配置
- 生成 ZIP、TGZ 压缩包
- 设置包的元信息
- 创建源码包 vs 二进制包
- 组件打包

## 关键概念

### 1. CPack 简介

CPack 是 CMake 的打包工具，可以生成多种格式的安装包：

| 生成器 | 格式 | 平台 |
|--------|------|------|
| ZIP | .zip | 跨平台 |
| TGZ | .tar.gz | 跨平台 |
| TBZ2 | .tar.bz2 | 跨平台 |
| NSIS | .exe | Windows |
| WIX | .msi | Windows |
| DEB | .deb | Debian/Ubuntu |
| RPM | .rpm | RedHat/CentOS |
| DragNDrop | .dmg | macOS |
| productbuild | .pkg | macOS |

### 2. 基本配置

```cmake
# 包信息
set(CPACK_PACKAGE_NAME "MyMathApp")
set(CPACK_PACKAGE_VENDOR "MyCompany")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A simple math application")

# 版本号
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

# 许可证文件
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/License.txt")

# 必须在最后包含 CPack
include(CPack)
```

### 3. 二进制包 vs 源码包

**二进制包**：包含编译好的程序
```bash
cd build
cpack -G ZIP
cpack -G TGZ
```

**源码包**：包含源代码
```bash
cd build
cpack --config CPackSourceConfig.cmake
```

### 4. 系统依赖库

```cmake
# 自动包含 VC++ 运行时库等系统依赖
include(InstallRequiredSystemLibraries)
```

### 5. 组件打包

可以将安装内容分成不同组件，用户可以选择安装：

```cmake
# 定义组件
set(CPACK_COMPONENTS_ALL Runtime Development)

# 组件名称
set(CPACK_COMPONENT_RUNTIME_DISPLAY_NAME "Application")
set(CPACK_COMPONENT_DEVELOPMENT_DISPLAY_NAME "Development Files")

# 组件描述
set(CPACK_COMPONENT_RUNTIME_DESCRIPTION "Main application")
set(CPACK_COMPONENT_DEVELOPMENT_DESCRIPTION "Headers and libraries")

# 组件依赖
set(CPACK_COMPONENT_DEVELOPMENT_DEPENDS Runtime)
```

## 项目结构

```
Step4-CPack/
├── CMakeLists.txt
├── README.md
├── cmake/
│   └── CPackConfig.cmake    # CPack 配置
├── packaging/
│   ├── License.txt          # 许可证
│   ├── Description.txt      # 描述
│   └── Welcome.txt          # 欢迎页
└── src/
    ├── main.cpp
    └── mymath/
        ├── CMakeLists.txt
        ├── mymath.cpp
        └── mymath.h
```

## 构建和打包

```bash
# 配置
cmake -S . -B build

# 构建
cmake --build build

# 生成 ZIP 包
cd build
cpack -G ZIP

# 生成 TGZ 包
cpack -G TGZ

# 生成源码包
cpack --config CPackSourceConfig.cmake

# 查看生成的包
ls *.zip *.tar.gz
```

## 生成的包

运行 `cpack -G ZIP` 后会生成：
```
MyMathApp-1.0.0-<平台>.zip
```

包的内容：
```
MyMathApp-1.0.0-Linux/
├── bin/
│   └── myapp
├── include/
│   ├── mymath.h
│   └── mymath_export.h
└── lib/
    └── libmymath.so...
```

## 常用 CPack 命令

```bash
# 使用特定生成器
cpack -G <GENERATOR>

# 显示详细输出
cpack -V

# 指定配置（Debug/Release）
cpack -C Release

# 打包特定组件
cpack -G ZIP -D CPACK_COMPONENTS_ALL="Runtime"

# 使用源码包配置
cpack --config CPackSourceConfig.cmake
```

## CPACK 变量参考

| 变量 | 说明 |
|------|------|
| `CPACK_PACKAGE_NAME` | 包名 |
| `CPACK_PACKAGE_VERSION` | 版本号 |
| `CPACK_PACKAGE_VENDOR` | 供应商 |
| `CPACK_PACKAGE_DESCRIPTION_SUMMARY` | 简短描述 |
| `CPACK_PACKAGE_DESCRIPTION_FILE` | 详细描述文件 |
| `CPACK_RESOURCE_FILE_LICENSE` | 许可证文件 |
| `CPACK_RESOURCE_FILE_README` | README 文件 |
| `CPACK_RESOURCE_FILE_WELCOME` | 欢迎页文件 |
| `CPACK_PACKAGE_FILE_NAME` | 生成的包文件名 |
| `CPACK_GENERATOR` | 默认生成器 |
| `CPACK_SOURCE_GENERATOR` | 源码包生成器 |
| `CPACK_SOURCE_IGNORE_FILES` | 源码包排除文件 |

## 下一步

继续学习 [Step5-NSIS](../Step5-NSIS/README.md)，了解如何创建 Windows 安装程序。
