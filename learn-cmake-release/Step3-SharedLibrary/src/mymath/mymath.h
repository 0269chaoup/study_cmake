#ifndef MYMATH_H
#define MYMATH_H

// 包含生成的导出头文件
// 这个文件由 generate_export_header() 生成
// 它定义了 MYMATH_API 宏，用于跨平台导出符号
#include "mymath_export.h"

namespace mymath {

// 使用 MYMATH_API 宏修饰要导出的函数
// 在 Windows DLL 中，这会展开为 __declspec(dllexport) 或 __declspec(dllimport)
// 在其他平台上，这通常展开为空或 __attribute__((visibility("default")))

// 计算平方根
MYMATH_API double sqrt(double x);

// 计算平方
MYMATH_API double square(double x);

} // namespace mymath

#endif // MYMATH_H
