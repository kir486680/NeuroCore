#include <boost/asio.hpp>
#include <chrono>
#include <iostream>
#include <random>
#include <vector>
#include <bitset>
#include <cmath>


class Float16 {
private:
    uint16_t data;
    static constexpr int signBits = 1;
    static constexpr int exponentBits = 5;
    static constexpr int fractionBits = 10;
    static constexpr int exponentBias = (1 << (exponentBits - 1)) - 1;

public:
    Float16() : data(0) {}

    static Float16 fromFloat32(float num) {
        Float16 f16;

        // Interpret the bits of the float as a uint32_t
        uint32_t floatBits;
        std::memcpy(&floatBits, &num, sizeof(floatBits));

        uint16_t sign = (floatBits >> 31) & 0x1;
        int16_t exponent = ((floatBits >> 23) & 0xFF) - 127 + exponentBias;
        uint16_t fraction = (floatBits >> (23 - fractionBits)) & ((1 << fractionBits) - 1);

        if (exponent >= 31) {
            // Handle overflow or special values (infinity, NaN)
            exponent = 31;
            fraction = (floatBits & 0x7FFFFF) ? 0x200 : 0; // NaN if fraction is non-zero
        } else if (exponent <= 0) {
            // Handle underflow or denormalized numbers
            if (exponent < -10) {
                // Too small to be represented as a denormalized number
                return Float16();
            }
            // Shift the fraction to represent a denormalized number
            fraction = (fraction | (1 << fractionBits)) >> (1 - exponent);
            exponent = 0;
        }

        f16.data = (sign << 15) | (exponent << fractionBits) | fraction;
        return f16;
    }

    // static float fromFloat16(Float16 num){
    //     float num;

    // }
};





int main(){

    float example = 3.14f;
    Float16 float16Value = Float16::fromFloat32(example);
    return 0;
}