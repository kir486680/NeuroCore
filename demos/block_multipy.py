import numpy as np

def multiply(*args):
    """
    Custom multiply function that takes elements of A and B matrices as separate parameters.
    The first half of the arguments are elements of A, and the second half are elements of B.
    """
    A_elements = args[:j*k]
    B_elements = args[j*k:]

    # Initialize the result array with zeros. It will store the product of A and B.
    result = [0] * (j * k)

    # Iterate through each row of A and each column of B to compute the product
    for row in range(j):
        for col in range(k):
            for inner in range(k):
                # The element at [row, col] in the result is the dot product of the
                # row from A and column from B.
                result[row*k + col] += A_elements[row*k + inner] * B_elements[inner*k + col]
                print(f"Multiplying A[{row}][{inner}] with B[{inner}][{col}] and adding to result[{row}][{col}]")

    return result

def get_block(matrix, start_row, start_col, total_cols):
    """
    Extracts a block of size jxk from a flattened matrix starting from position (start_row, start_col).
    """
    print(f"Extracting a {j}x{k} block starting at ({start_row}, {start_col})")
    block = [0] * (j * k)  # Initialize block with zeros

    # Iterate over each position in the block
    for row in range(j):
        for col in range(k):
            actual_row = start_row + row
            actual_col = start_col + col
            print(f"Checking position ({actual_row}, {actual_col}) in the original matrix")

            if actual_row < len(matrix) // total_cols and actual_col < total_cols:
                block_index = row * j + col #if block was not flat this would be block[row][col]
                matrix_index = actual_row * total_cols + actual_col
                block[block_index] = matrix[matrix_index]
                print(f"Adding element at index {matrix_index} to the block at index {block_index}, so it is {matrix[matrix_index]}")

    return block

def block_multiply(M, N, m, p, n, j, k):
    """
    Perform block matrix multiplication of flattened matrices M and N with block size jxk.
    """
    print("Starting block matrix multiplication")
    result = [0] * (m * n)

    # Iterate over blocks of matrix M and N
    for i in range(0, m, j): # multiplying ith row in A with every jth column of B before moving to the next row
        for l in range(0, n, k):
            for r in range(0, p, k):
                # Extract blocks from M and N
#in matrix multiplication, we always change the column of A, so we are using r as the column index which always changes
                M_block = get_block(M, i, r, p)
#in matrix multiplication, we always change the row of B, so we are using r as the row index which always changes
                N_block = get_block(N, r, l, n)
                print(f"Blocks to multiply: {M_block} and {N_block}")

                # Multiply and accumulate the results
                multiplied_block = multiply(*(M_block + N_block)) #result is a list of length j*k
                #Now, we want to add the multiplied block to the result matrix
                # Iterate over each row and column in the block
                for row in range(j):
                    for col in range(k):
                        # Calculate the actual position in the result matrix
                        result_row = i + row
                        result_col = l + col
                        print(f"The actual position of the block ({result_row}, {result_col}) in the result matrix")
                        # Check if the actual position is within the bounds of the result matrix
                        if result_row < m and result_col < n:
                            # Calculate the index in the flattened result matrix where the current element should be added
                            result_index = result_row * n + result_col
                            # Calculate the index in the multiplied block to fetch the current element
                            block_index = row * k + col
                            # Add the element from the multiplied block to the corresponding position in the result matrix
                            result[result_index] += multiplied_block[block_index]
                            # Print the details of the operation
                            print(f"Adding element from multiplied block at index {block_index} to result at position ({result_row}, {result_col}), index {result_index}")


    return result

# Example usage
j, k = 2, 2  # Block size
M = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]  # Example flattened matrices
N = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
m, p, n = 3, 4, 3  # Dimensions of M and N
result = block_multiply(M, N, m, p, n, j, k)
print("Final result:", result)
