#include <iostream>
#include <mymath.h>  // 来自 MyMath 库

int main(int argc, char* argv[]) {
    std::cout << "==================================" << std::endl;
    std::cout << "Consumer App using MyMath Library" << std::endl;
    std::cout << "==================================" << std::endl;

    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <number>" << std::endl;
        std::cout << "Example: " << argv[0] << " 16" << std::endl;
        return 1;
    }

    double inputValue = std::stod(argv[1]);

    // 使用 MyMath 库的函数
    double sqrtResult = mymath::sqrt(inputValue);
    double squareResult = mymath::square(inputValue);

    std::cout << std::endl;
    std::cout << "Input: " << inputValue << std::endl;
    std::cout << "Square root: " << sqrtResult << std::endl;
    std::cout << "Square: " << squareResult << std::endl;
    std::cout << std::endl;
    std::cout << "MyMath library is working correctly!" << std::endl;

    return 0;
}
