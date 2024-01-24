//pretty much same as https://github.com/fedetft/serial-port/blob/master/1_simple/SimpleSerial.h
#ifndef _SERIAL_H
#define	_SERIAL_H

#include <boost/asio.hpp>

class Serial{
    private:
        boost::asio::io_service io;
        boost::asio::serial_port port;
    
    public:
    //io() and port(io, portName) function will be executed before the constructor
        Serial(std::string portName, int baudRate) : io(), port(io, portName){//
            port.set_option(boost::asio::serial_port_base::baud_rate(baudRate));
        }

        void writeString(std::string s){
            boost::asio::write(port, boost::asio::buffer(s.c_str(), s.size()));
        }
        std::string readLine(){
            //Reading data char by char, code is optimized for simplicity, not speed
            using namespace boost;
            char c;
            std::string result;
            for(;;){
                asio::read(port, asio::buffer(&c, 1));
                switch(c){
                    case '\r':
                        break;
                    case '\n':
                        return result;
                    default:
                        result += c;
                }
            }
        }
        char readByte(){
            char byte;
            boost::asio::read(port, boost::asio::buffer(&byte, 1));
            return byte;
        }
};

#endif 