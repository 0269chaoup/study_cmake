#include "mymath.h"
#include <cmath>

namespace mymath {

double sqrt(double x) {
    if (x < 0) {
        return std::nan("");
    }
    return std::sqrt(x);
}

double square(double x) {
    return x * x;
}

} // namespace mymath
