import numpy as np 

def float_to_float16(value):
    # Convert Python float to numpy float16
    float16 = np.float16(value)
    # Convert to binary string and strip the '0b' prefix
    return format(np.float16(float16).view(np.uint16), '016b')