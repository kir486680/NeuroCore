import serial
from bitstring import BitArray
import time
import numpy as np


# Configure the serial connection
ser = serial.Serial(
    port='/dev/cu.usbserial-ibF7lQmu1',  # Replace with your serial port name
    baudrate=9600, # Set to the baud rate of your UART communication
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)


#creat a function to convert foat16 to two 8 bit bytes
def float16_to_8bit_bytes(value):
    # Ensure the input is a numpy float16
    if not isinstance(value, np.float16):
        raise TypeError("Input must be a numpy float16.")

    # Convert the float16 to a 16-bit integer representation
    int_representation = np.frombuffer(value.tobytes(), dtype=np.uint16)[0]

    # Extract the high and low bytes
    high_byte = int_representation >> 8
    low_byte = int_representation & 0xFF

    return (high_byte, low_byte)


def binary_strings_to_float16(high_byte_str, low_byte_str):

    if len(high_byte_str) != 8 or len(low_byte_str) != 8:
        raise ValueError("Both strings must be 8 bits long.")

    # Convert binary strings to integers
    high_byte = int(high_byte_str, 2)
    low_byte = int(low_byte_str, 2)

    # Combine the high and low bytes into a 16-bit integer
    int_representation = (high_byte << 8) | low_byte

    # Convert the 16-bit integer back to a float16
    float_value = np.frombuffer(np.array([int_representation], dtype=np.uint16).tobytes(), dtype=np.float16)[0]

    return float_value



# Check if the serial port is open




for i in range(100):
    if not ser.is_open:
        ser.open()
    # Send the initial start byte
    ser.write(b'\xFE')
    # Wait a bit for the transmission to complete
    time.sleep(0.1)
    #generate numpy array of length 8 of normal values 
    weights = np.random.normal(size=8)
    print("Sending weights:", weights)
    for i in range(8):
        float16 = np.float16(weights[i])
        print("Sending float16:", float16)
        high, low = float16_to_8bit_bytes(float16)
        high = bytes([high])
        low = bytes([low])
        # Send the first byte of the float
        ser.write(high)  # Replace with the actual byte you want to send
        # Wait a bit for the transmission to complete
        time.sleep(0.1)
        # Send the second byte of the float
        ser.write(low)  # Replace with the actual byte you want to send
        # Wait a bit for the transmission to complete
        time.sleep(0.1)


    # Send the last byte
    ser.write(b'\xFF')
    # Wait a bit for the transmission to complete
    #time.sleep(0.1)


    history = []
    history_total = []
    total_array = []
    #reading the resultant 2x2 matrix
    while True:
        # Read the received byte
        byte = ser.read()
        
        if byte:
            byte = BitArray(byte).bin
            if byte == '11111110':
                print("Start of transmission")
            elif byte == '11111111' and len(history_total) == 8:
                print("End of transmission")
                #break out of the while loop
                break
            else:
                print("Received byte:", byte)
                history.append(byte)
                history_total.append(byte)
            if len(history) == 2:
                print("Received final bytes:", history)
                float16_value = binary_strings_to_float16(history[0], history[1])
                total_array.append(float16_value)
                print("Received float16 value:", float16_value)
                history = []
        else:
            print("Empty")
        time.sleep(0.05)
    history_total = []
    print("Total array:", total_array)
    total_array = []
    # Close the serial connection
    ser.close()
