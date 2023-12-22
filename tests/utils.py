import numpy as np 

def print_matrix(matrix, rows, cols, title="Matrix"):
    """
    Prints a matrix in a 2D format from an array of BinaryValue objects.

    :param matrix: List or array of BinaryValue objects representing the matrix.
    :param rows: Number of rows in the matrix.
    :param cols: Number of columns in the matrix.
    :param title: The title to print above the matrix.
    """

    print(f"\n{title}:")
    rows = int(rows)
    cols = int(cols)
    for row in range(rows):
        for col in range(cols):
            idx = row * cols + col
            # Assumes binary_to_float16 is a function that converts a binary string to a float16
            val = binary_to_float16(matrix[idx].value)
            print(f"{val:5.2f}", end=" ")
        print()


def float_to_float16(value):
    # Convert Python float to numpy float16
    float16 = np.float16(value)
    # Convert to binary string and strip the '0b' prefix
    return format(np.float16(float16).view(np.uint16), '016b')

def binary_to_float16(value):
    try:
        value = value.binstr
        int_value = int(value, 2) #convert cocotb binary value to binary string 
        # Convert binary string to numpy float16
        float16 = np.frombuffer(np.array([int_value], dtype=np.uint16).tobytes(), dtype=np.float16)[0]
        # Convert to Python float
        return float16
    except ValueError:
        # If the value is not a binary string, return the original value
        return float('nan')