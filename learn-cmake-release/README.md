# CMake Install/Pack/发布 学习项目

本项目是一个渐进式教程，帮助你系统学习 CMake 的 install、pack 和发布流程。

## 项目结构

```
learn-cmake-release/
├── Step1-BasicInstall/      # 基础安装
├── Step2-GNUInstallDirs/    # GNUInstallDirs 标准目录
├── Step3-SharedLibrary/     # 共享库与版本控制
├── Step4-CPack/             # CPack 基础打包
├── Step5-NSIS/              # Windows NSIS 安装包
├── Step6-Export/            # 库导出与 find_package 支持
└── consumer-project/        # find_package 消费者示例
```

## 学习路径

### Step1: 基础安装 (BasicInstall)
学习内容：
- `install(TARGETS)` 安装可执行文件
- `install(FILES)` 安装头文件
- `CMAKE_INSTALL_PREFIX` 的使用
- 静态库的安装

### Step2: GNUInstallDirs 标准目录
学习内容：
- `include(GNUInstallDirs)` 模块
- 标准目录变量：`CMAKE_INSTALL_BINDIR`, `CMAKE_INSTALL_LIBDIR`, `CMAKE_INSTALL_INCLUDEDIR`
- `COMPONENT` 分组安装
- 安装配置文件

### Step3: 共享库与版本控制 (SharedLibrary)
学习内容：
- `BUILD_SHARED_LIBS` 选项
- `GenerateExportHeader` 生成导出宏
- 设置 `VERSION` 和 `SOVERSION`
- RPATH 配置（Linux/macOS）
- Windows DLL 处理

### Step4: CPack 基础打包
学习内容：
- CPack 基础配置
- 生成 ZIP、TGZ 压缩包
- 设置包的元信息
- 源码包 vs 二进制包

### Step5: Windows NSIS 安装包
学习内容：
- NSIS 安装包配置
- 自定义安装界面图标
- 开始菜单/桌面快捷方式
- 添加到系统 PATH
- 卸载程序

### Step6: 库导出与 find_package 支持
学习内容：
- `install(EXPORT)` 导出目标
- `configure_package_config_file()` 生成 Config.cmake
- `write_basic_package_version_file()` 生成版本文件
- `NAMESPACE` 别名
- 让其他项目通过 `find_package()` 使用

## 快速开始

每个 Step 目录都可以独立构建和测试：

```bash
# 进入某个 Step 目录
cd learn-cmake-release/Step1-BasicInstall

# 配置项目，指定安装目录
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install

# 构建
cmake --build build

# 安装
cmake --install build

# 查看安装结果
ls ./install/
```

## CPack 打包（Step4 及以后）

```bash
cd build

# 生成 ZIP 包
cpack -G ZIP

# 生成 TGZ 包
cpack -G TGZ

# Windows: 生成 NSIS 安装包（需要安装 NSIS）
cpack -G NSIS
```

## find_package 测试（Step6）

```bash
# 首先安装 Step6-Export
cd learn-cmake-release/Step6-Export
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=./install
cmake --build build
cmake --install build

# 然后构建消费者项目
cd ../consumer-project
cmake -S . -B build -DMyMath_DIR=../Step6-Export/install/lib/cmake/MyMath
cmake --build build

# 运行
./build/consumer      # Linux/macOS
.\build\Debug\consumer.exe  # Windows
```

## 平台说明

- **Windows**: 建议使用 Visual Studio 或 MinGW-w64
- **Linux**: 使用 GCC 或 Clang
- **macOS**: 使用 Clang (Xcode Command Line Tools)

## 依赖

- CMake 3.15 或更高版本
- C++11 兼容的编译器
- NSIS (仅 Step5，用于创建 Windows 安装包)

## 参考资源

- [CMake install() 命令文档](https://cmake.org/cmake/help/latest/command/install.html)
- [CPack 文档](https://cmake.org/cmake/help/latest/module/CPack.html)
- [GNUInstallDirs 文档](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
