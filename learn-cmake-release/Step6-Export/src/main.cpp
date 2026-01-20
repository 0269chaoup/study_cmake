#include <iostream>
#include "mymath/mymath.h"

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <number>" << std::endl;
        std::cout << "Calculate the square root of the given number." << std::endl;
        return 1;
    }

    double inputValue = std::stod(argv[1]);

    double result = mymath::sqrt(inputValue);

    std::cout << "The square root of " << inputValue << " is " << result << std::endl;
    std::cout << inputValue << " squared is " << mymath::square(inputValue) << std::endl;

    return 0;
}
