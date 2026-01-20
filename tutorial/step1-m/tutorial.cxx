// A simple program that computes the square root of a number
#include <cmath>
#include <cstdlib> // TODO 5: Remove this line
#include <iostream>
#include <string>

// TODO 11: Include TutorialConfig.h
#include "TutorialConfig.h"
//argc is the number of arguments passed to the program from the command line including the name of the program itself.
//argv is an array of character pointers listing all the arguments.
//argv[0] is the name of the program, or an empty string if the name is not available.
//argv[1] is the first argument, argv[2] is the second argument, and so on.
int main(int argc, char* argv[])
{
  if (argc < 2) {
    // TODO 12: Create a print statement using Tutorial_VERSION_MAJOR
    //          and Tutorial_VERSION_MINOR
    std::cout << argv[0] << " Version " << Tutorial_VERSION_MAJOR << "."
              << Tutorial_VERSION_MINOR << std::endl;
    std::cout << "Usage: " << argv[0] << " number" << std::endl;
    return 1;
  }

  // convert input to double
  // TODO 4: Replace atof(argv[1]) with std::stod(argv[1])
  // atof converts a  ASCII string to a double
  // stod converts a string to a double
  // 两者的区别：atof 是把一个const char* 类型转换为 double 类型，而 stod 是把一个 string 类型转换为 double 类型。
  // atof 会忽略前面的空格，直到遇到第一个非空格字符，然后开始转换，直到遇到非数字字符为止，如果遇到非数字字符，则不会进行转换，如果没有数字，则返回 0.0。
  // stod 会忽略前面的空格，直到遇到第一个非空格字符，然后开始转换，直到遇到非数字字符为止，如果遇到非数字字符，则不会进行转换，如果没有数字，则抛出异常。
  const double inputValue = std::stod(argv[1]);

  // calculate square root
  const double outputValue = sqrt(inputValue);
  std::cout << "The square root of " << inputValue << " is " << outputValue
            << std::endl;
  return 0;
}
