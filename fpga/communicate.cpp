#include "Serial.h"
#include <iostream>
#include <random>
#include <vector>
#include <bitset>
#include <cmath>
#include <chrono>
#include <thread>

class Float16 {
private:
    uint16_t data;
    static constexpr int signBits = 1;
    static constexpr int exponentBits = 5;
    static constexpr int fractionBits = 10;
    static constexpr int exponentBias = (1 << (exponentBits - 1)) - 1;

public:
    Float16() : data(0) {}
    //constructor to create float16 from uint16_t
    Float16(uint16_t data) : data(data) {}

    std::pair<char, char> getBytes() const {
        char highByte = static_cast<char>(data >> 8);
        char lowByte = static_cast<char>(data & 0xFF);
        return {highByte, lowByte};
    }

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

    float toFloat32() const{
        uint32_t floatBits;
        float num;

        uint16_t sign = (data >> 15) & 0x1;
        int16_t exponent = ((data >> fractionBits) & 0x1F) - exponentBias + 127;
        uint16_t fraction = data & ((1 << fractionBits) - 1);

        //just add the exponent and fraction to the floatBits
        floatBits = (sign << 31) | (exponent << 23) | (fraction << (23 - fractionBits));
        std::memcpy(&num, &floatBits, sizeof(num));
        return num;
        
    }
};





int main(){


    std::vector<Float16> float16Vector;
    for (int i = 0; i < 8; i++){//we are going to send 8 numbers
        float16Vector.push_back(Float16::fromFloat32(i));
    }

    Serial serial("/dev/cu.usbserial-ibF7lQmu1", 9600);
    serial.writeString("\xFE"); // Start byte

    for (const auto& f16 : float16Vector) {
        auto [highByte, lowByte] = f16.getBytes();
        //cout the bytes
        std::cout << std::bitset<8>(highByte) << " " << std::bitset<8>(lowByte) << std::endl;
        serial.writeString(std::string(1, highByte));
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        //time.sleep(0.1)
        serial.writeString(std::string(1, lowByte));
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    serial.writeString("\xFF"); // End byte

    //Now, we read the data from the FPGA
    char byte;
    std::vector<char> receivedBytes;
    while (true){
        byte = serial.readByte();
        if(byte == '\xFE'){
            std::cout << "Start byte received" << std::endl;
        }
        else if(byte == '\xFF'){
            std::cout << "End byte received" << std::endl;
            break;
        }
        else{
            //std::cout << "Byte received: " << byte << std::endl;
            receivedBytes.push_back(byte);
            //check if len of receivedBytes is 2
            if(receivedBytes.size() == 2){
                //we have received 2 bytes, so we can convert them to a float16
                char highByte = receivedBytes[0];
                char lowByte = receivedBytes[1];
                uint16_t data = (static_cast<uint16_t>(highByte) << 8) | static_cast<uint16_t>(lowByte);
                Float16 f16(data);
                std::cout << "Float16: " << f16.toFloat32() << std::endl;
                receivedBytes.clear();
            }
            
        }
        
        std::this_thread::sleep_for(std::chrono::milliseconds(100));

    }

    return 0;
}