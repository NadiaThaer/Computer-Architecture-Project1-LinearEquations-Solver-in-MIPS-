.data
menu: .asciiz "\nMenu:\n1 - Print content of the file\n2 - Print value of N\n3 - Print content of the buffer\n4 - Print variable array\n5 - Print coefficient matrix\n6 - Solving 2*2 \n7 - Solving 3*3 \nE - Exit\nEnter your choice: "
filename: .asciiz "input.txt"
debug_open: .asciiz "Debug: File opened successfully.\n"
debug_read: .asciiz "Debug: Number of bytes read: "
debug_buffer: .asciiz "Debug: Buffer content:\n"
debug_line: .asciiz "Number of lines read so far: "  # Debug message for line count
error_open: .asciiz "Error: Failed to open file.\n"
buffer: .space 3000         # Buffer to store file content
newline : .asciiz "\n"
N: .word 0
msg : .asciiz "\n the num of line was :\n"
var_array:       .word      # Example variable array
coeff_matrix:    .word 0, 0, 0, 0, 0, 0, 0, 0, 0  # Example 3x3 matrix
result_array:    .word 0,0,0,0,0,0,0,0,0    # Example result array
x_label: .asciiz "x"
y_label: .asciiz "y"
z_label: .asciiz "z"


# Declare variables to store the numerators and denominator
result_x_numerator: .word 0
result_y_numerator: .word 0
result_denominator: .word 0


x_result_label:       .asciiz "x = "
y_result_label:       .asciiz "y = "

division_by_zero:     .asciiz "Error: Division by ZERO\n"

slash:                .asciiz " / "

# Coefficients for the 3x3 system of equations
coefficient_3x3_1:    .word 2  # a1
coefficient_3x3_2:    .word 3  # b1
coefficient_3x3_3:    .word 1  # c1
constant_3x3_1:       .word 5  # d1

coefficient_3x3_4:    .word 4  # a2
coefficient_3x3_5:    .word 2  # b2
coefficient_3x3_6:    .word 2  # c2
constant_3x3_2:       .word 8 # d2

coefficient_3x3_7:    .word 1  # a3
coefficient_3x3_8:    .word 1  # b3
coefficient_3x3_9:    .word 2  # c3
constant_3x3_3:       .word 6  # d3

# Coefficients for a 2x2 system of equations
# Equation format: ax + by = c
# Example: x + y = 5
#          2x + y = 10
zero_determinant_msg: .asciiz "Error: Determinant is zero. The system cannot be solved.\n"

# Coefficients for 2x2 system:
# 1x + 1y = 5
# 2x + 1y = 10

coefficient1: .word 1    # Coefficient a1 (1)
coefficient2: .word 1    # Coefficient b1 (1)
constant1:    .word 5    # Constant c1 (5)

coefficient3: .word 2    # Coefficient a2 (2)
coefficient4: .word 1    # Coefficient b2 (1)
constant2:    .word 10   # Constant c2 (10)

# Result storage
result_x:     .word 0    # Store result fo
result_y:     .word 0    # Store result for y
.text
main:
    # Display the menu
    li $v0, 4
    la $a0, menu
    syscall

    # Read user choice
    li $v0, 8               # Read string input
    la $a0, buffer          # Store choice in buffer
    li $a1, 2               # Allow 1 character + null terminator
    syscall

    lb $t0, buffer          # Load the first character of input

    # Check user input and call corresponding option
    li $t1, '1'
    beq $t0, $t1, option1   # If choice = 1
    li $t1, '2'
    beq $t0, $t1, option2   # If choice = 2
    li $t1, '3'
    beq $t0, $t1, option3   # If choice = 3
    li $t1, '4'
    beq $t0, $t1, option4   # If choice = 4
    li $t1, '5'
    beq $t0, $t1, option5   # If choice = 5
    li $t1, '6'
    beq $t0, $t1, option6   # If choice = 6
    li $t1, '7'
    beq $t0, $t1, option7   # If choice = 7
    li $t1, 'E'
    
    beq $t0, $t1, exit      # If choice = E
    j main                  # Invalid input, redisplay menu

option1:
la   $a0, newline  # Load address of newline string into $a0

    # Set syscall number for printing a string (service 4)
    li   $v0, 4        # Syscall for print_string

    # Make the syscall to print the newline
    syscall            # Perform syscall to print the newline
     # Open the file
    li $v0, 13             # Syscall for opening file
    la $a0, filename       # File name
    li $a1, 0              # Read-only mode
    li $a2, 0              # Default permissions
    syscall

    # Check if file opened successfully
    bltz $v0, error        # If $v0 < 0, file open failed
    move $t1, $v0          # Store file descriptor in $t1

   

    # Initialize counters
    li $t4, 0              # Offset in the buffer
    li $t6, 0              # Line counter (number of lines read)

read_file:
    # Read a chunk from the file
    li $v0, 14             # Syscall to read from file
    move $a0, $t1          # File descriptor
    la $t2, buffer         # Address of the buffer
    add $t7, $t4, $t2      # Calculate the address (buffer + offset)
    move $a1, $t7          # Move the result into $a1 for the syscall

    li $a2, 8             # Maximum bytes to read
    syscall

    # Check if EOF (end of file) is reached
    beqz $v0, end_read     # Exit loop if $v0 == 0 (no bytes read)

    # Count newline characters in the chunk
    move $t3, $a1          # Start address of the chunk read
    add $t8, $t3, $v0      # End address of the chunk read (start + bytes read)

count_newlines:
    lb $t9, 0($t3)         # Load a byte from the chunk
    beqz $t9, update_count # If null byte, end of buffer
    beq $t9, 10, increment_line # If newline character ('\n'), increment counter
    j next_char            # Otherwise, go to the next character

increment_line:
    addi $t6, $t6, 1       # Increment the line counter

next_char:
    addi $t3, $t3, 1       # Move to the next character
    bne $t3, $t8, count_newlines # Continue until end of chunk

update_count:
    # Increment buffer offset
    sw $t6, N
    add $t4, $t4, $v0      # Update buffer offset by bytes read
    
    j read_file            # Continue reading the next chunk

end_read:
# Null-terminate buffer
    la $t2, buffer
    add $t2, $t2, $t4
    sb $zero, 0($t2)
    # Close the file
    li $v0, 16             # Syscall to close file
    move $a0, $t1          # File descriptor
    syscall

    # Debug: Print the total number of lines read
    li $v0, 4
    la $a0, debug_line
    syscall
    li $v0, 1
    move $a0, $t6          # Print $t6 (total lines read)
    syscall

    # Debug: Print buffer content
    # Print a newline character
    li $v0, 4          # Load syscall code for print string
    la $a0, newline    # Load address of the newline string
    syscall            # Perform the syscall
    li $v0, 4
    la $a0, debug_buffer
    syscall
    li $v0, 4
    la $a0, buffer
    syscall

    j main                 # Go back to the main menu

error:
    # Print error message
    li $v0, 4
    la $a0, error_open
    syscall
    j main                 # Go back to the main menu


option2:
    # Print the value of N
    li $v0, 4            # Syscall for printing a string
    la $a0, msg          # Load address of message
    syscall

    li $v0, 1            # Syscall for printing an integer
    lw $a0, N            # Load the value of N into $a0
    syscall
    j main

option3:
    # Open the file (repeat logic from Option 1)
    li $v0, 13             # Syscall for opening file
    la $a0, filename       # File name
    li $a1, 0              # Read-only mode
    li $a2, 0              # Default permissions
    syscall

    bltz $v0, error        # If file open fails
    move $t1, $v0          # File descriptor

    # Reset buffer and offset
    li $t4, 0
    la $t2, buffer         # Start address of buffer

read_file_option3:
    li $v0, 14             # Syscall to read from file
    move $a0, $t1
    add $t7, $t4, $t2
    move $a1, $t7
    li $a2, 8              # Max bytes to read
    syscall

    beqz $v0, end_option3  # If EOF, stop reading
    add $t4, $t4, $v0      # Update offset
    j read_file_option3    # Continue reading

end_option3:
    li $v0, 16             # Syscall to close file
    move $a0, $t1
    syscall

    # Print a newline for formatting
    li $v0, 4             # Syscall for printing a string
    la $a0, newline       # Load the address of the newline string
    syscall

    # Print buffer content
    la $a0, buffer
    li $v0, 4
    syscall
    j main





option4:
    # Load the buffer address and initialize the counter
    la $t0, buffer         # Base address of the buffer
    li $t1, 0              # Index in the buffer
    li $t2, 0              # Variable index for storing in var_array
    la $t3, var_array      # Load the address of the var_array

trace_buffer:
    lb $t4, 0($t0)         # Load a byte from the buffer
    beqz $t4, end_option4  # If null terminator, end tracing

    # Look for variable names ('x', 'y', 'z')
    li $t5, 120            # ASCII 'x'
    li $t6, 121            # ASCII 'y'
    li $t7, 122            # ASCII 'z'

    # Check if the current character is 'x', 'y', or 'z'
    beq $t4, $t5, store_x  # If 'x', store its value
    beq $t4, $t6, store_y  # If 'y', store its value
    beq $t4, $t7, store_z  # If 'z', store its value
    j next_char_1

store_x:
    # Read the next byte (the value after 'x')
    addi $t0, $t0, 2       # Move to next character (skip 'x')
    lb $t8, 0($t0)         # Load the value (assume it's a single digit or character)
    sw $t8, 0($t3)         # Store value in the var_array at index 0
    addi $t3, $t3, 4       # Move to the next slot in the var_array
    j next_char_1

store_y:
    # Read the next byte (the value after 'y')
    addi $t0, $t0, 2       # Move to next character (skip 'y')
    lb $t8, 0($t0)         # Load the value (assume it's a single digit or character)
    sw $t8, 0($t3)         # Store value in the var_array at index 1
    addi $t3, $t3, 4       # Move to the next slot in the var_array
    j next_char_1

store_z:
    # Read the next byte (the value after 'z')
    addi $t0, $t0, 2       # Move to next character (skip 'z')
    lb $t8, 0($t0)         # Load the value (assume it's a single digit or character)
    sw $t8, 0($t3)         # Store value in the var_array at index 2
    addi $t3, $t3, 4       # Move to the next slot in the var_array
    j next_char_1

next_char_1:
    addi $t0, $t0, 1       # Move to the next character in the buffer
    j trace_buffer         # Continue tracing the buffer

end_option4:
    # Print the variable names and their respective values in separate lines.
     # Print new line
    li $v0, 4           # syscall for print_string
    la $a0, newline     # load address of newline string into $a0
    syscall             # make the syscall
    # Print "x"
    li $v0, 4              # Syscall to print a string
    la $a0, x_label        # Label for x
    syscall

  

    # Print newline
    li $v0, 4              # Syscall to print a string
    la $a0, newline        # Print a newline
    syscall

    # Print "y"
    li $v0, 4              # Syscall to print a string
    la $a0, y_label        # Label for y
    syscall


    # Print newline
    li $v0, 4              # Syscall to print a string
    la $a0, newline        # Print a newline
    syscall

    # Print "z"
    li $v0, 4              # Syscall to print a string
    la $a0, z_label        # Label for z
    syscall

 
    # Print newline
    li $v0, 4              # Syscall to print a string
    la $a0, newline        # Print a newline
    syscall

    j main                  # Return to the main menu
option5:
    # Placeholder coefficient matrix (assume 3x3 for simplicity)
    la $t0, coeff_matrix   # Base address of matrix
    li $t1, 3              # Rows count
    li $t2, 3              # Columns count
print_matrix_row:
    beqz $t1, end_option5  # Exit if rows are exhausted
    li $t3, 3              # Reset column counter for the row

print_matrix_col:
    beqz $t3, next_row     # Move to the next row if columns are done
    lw $t4, 0($t0)         # Load matrix element
    li $v0, 1              # Print integer
    move $a0, $t4
    syscall
    # Print a space between elements
    li $v0, 4
    la $a0, newline
    syscall

    addi $t0, $t0, 4       # Move to next matrix element
    subi $t3, $t3, 1       # Decrement column counter
    j print_matrix_col

next_row:
    li $v0, 4              # Print newline after each row
    la $a0, newline
    syscall

    subi $t1, $t1, 1       # Decrement row counter
    j print_matrix_row

end_option5:
    j main






option6:
    # Print newline
    li $v0, 4              # Syscall to print a string
    la $a0, newline        # Print a newline
    syscall

    # Load coefficients of the first equation into registers
    lw $t0, coefficient1    # $t0 = a1 (1)
    lw $t1, coefficient2    # $t1 = b1 (1)
    lw $t2, constant1       # $t2 = c1 (5)

    # Load coefficients of the second equation into registers
    lw $t3, coefficient3    # $t3 = a2 (2)
    lw $t4, coefficient4    # $t4 = b2 (1)
    lw $t5, constant2       # $t5 = c2 (10)

    # Perform calculation to find x and y using Cramer's rule

    # Calculate the determinant (determinant = a1*b2 - a2*b1)
    mul $t6, $t0, $t4       # $t6 = a1 * b2 (1 * 1 = 1)
    mul $t7, $t3, $t1       # $t7 = a2 * b1 (2 * 1 = 2)
    sub $t8, $t6, $t7       # $t8 = determinant (1 - 2 = -1)

    # Calculate determinant_x (determinant_x = c1*b2 - c2*b1)
    mul $t9, $t2, $t4       # $t9 = c1 * b2 (5 * 1 = 5)
    mul $s0, $t5, $t1       # $s0 = c2 * b1 (10 * 1 = 10)
    sub $s1, $t9, $s0       # $s1 = determinant_x (5 - 10 = -5)

    # Calculate determinant_y (determinant_y = a1*c2 - a2*c1)
    mul $s2, $t0, $t5       # $s2 = a1 * c2 (1 * 10 = 10)
    mul $s3, $t3, $t2       # $s3 = a2 * c1 (2 * 5 = 10)
    sub $s4, $s2, $s3       # $s4 = determinant_y (10 - 10 = 0)

    # Store results in memory
    sw $s1, result_x_numerator  # Store determinant_x (numerator of x)
    sw $s4, result_y_numerator  # Store determinant_y (numerator of y)
    sw $t8, result_denominator  # Store determinant (denominator)

    # Check if the denominator is zero
    beqz $t8, division_by_zero_error  # If determinant (denominator) is 0, jump to error handling

    # Print x as a fraction (numerator/denominator)
    li $v0, 4              # Syscall to print a string
    la $a0, x_result_label # Print "x = "
    syscall

    li $v0, 1              # Print numerator of x
    move $a0, $s1          # Load determinant_x
    syscall

    li $v0, 4              # Print "/"
    la $a0, slash          # Slash character
    syscall

    li $v0, 1              # Print denominator of x
    move $a0, $t8          # Load determinant
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # Print y as a fraction (numerator/denominator)
    li $v0, 4              # Syscall to print a string
    la $a0, y_result_label # Print "y = "
    syscall

    li $v0, 1              # Print numerator of y
    move $a0, $s4          # Load determinant_y
    syscall

    li $v0, 4              # Print "/"
    la $a0, slash          # Slash character
    syscall

    li $v0, 1              # Print denominator of y
    move $a0, $t8          # Load determinant
    syscall

    # Jump back to main
    j main

# Error handling for division by zero
division_by_zero_error:
    li $v0, 4              # Syscall to print a string
    la $a0, division_by_zero   # Print "Error: Division by ZERO\n"
    syscall

    # Jump back to main
    j main







option7:
    # Print newline
    li $v0, 4              # Syscall to print a string
    la $a0, newline        # Load the address of the newline
    syscall

    # Load coefficients of the 3x3 system into registers
    lw $t0, coefficient_3x3_1    # $t0 = a1
    lw $t1, coefficient_3x3_2    # $t1 = b1
    lw $t2, coefficient_3x3_3    # $t2 = c1
    lw $t3, constant_3x3_1       # $t3 = d1

    lw $t4, coefficient_3x3_4    # $t4 = a2
    lw $t5, coefficient_3x3_5    # $t5 = b2
    lw $t6, coefficient_3x3_6    # $t6 = c2
    lw $t7, constant_3x3_2       # $t7 = d2

    lw $t8, coefficient_3x3_7    # $t8 = a3
    lw $t9, coefficient_3x3_8    # $t9 = b3
    lw $s0, coefficient_3x3_9    # $s0 = c3
    lw $s1, constant_3x3_3       # $s1 = d3

    # Convert integer values to floating-point
    mtc1 $t0, $f0    # Move a1 to $f0
    mtc1 $t1, $f1    # Move b1 to $f1
    mtc1 $t2, $f2    # Move c1 to $f2
    mtc1 $t3, $f3    # Move d1 to $f3

    mtc1 $t4, $f4    # Move a2 to $f4
    mtc1 $t5, $f5    # Move b2 to $f5
    mtc1 $t6, $f6    # Move c2 to $f6
    mtc1 $t7, $f7    # Move d2 to $f7

    mtc1 $t8, $f8    # Move a3 to $f8
    mtc1 $t9, $f9    # Move b3 to $f9
    mtc1 $s0, $f10   # Move c3 to $f10
    mtc1 $s1, $f11   # Move d3 to $f11

    # Calculate determinant
    mul.s $f12, $f5, $f10         # $f12 = b2 * c3
    mul.s $f13, $f9, $f6          # $f13 = b3 * c2
    sub.s $f14, $f12, $f13        # $f14 = b2*c3 - b3*c2

    mul.s $f15, $f4, $f10         # $f15 = a2 * c3
    mul.s $f16, $f8, $f6          # $f16 = a3 * c2
    sub.s $f17, $f15, $f16        # $f17 = a2*c3 - a3*c2

    mul.s $f18, $f4, $f9          # $f18 = a2 * b3
    mul.s $f19, $f8, $f5          # $f19 = a3 * b2
    sub.s $f20, $f18, $f19        # $f20 = a2*b3 - a3*b2

    mul.s $f21, $f0, $f14         # $f21 = a1 * (b2*c3 - b3*c2)
    mul.s $f22, $f1, $f17         # $f22 = b1 * (a2*c3 - a3*c2)
    mul.s $f23, $f2, $f20         # $f23 = c1 * (a2*b3 - a3*b2)
    add.s $f24, $f21, $f22        # $f24 = a1*(b2*c3 - b3*c2) - b1*(a2*c3 - a3*c2)
    add.s $f25, $f24, $f23        # $f25 = determinant

    # Check if determinant is close to zero
    li $t2, 1
    mtc1 $t2, $f26               # Threshold (1.0) into floating-point
    abs.s $f27, $f25             # Absolute value of determinant
    c.lt.s $f27, $f26            # Check if |determinant| < threshold
    bc1t error_division_by_zero  # Branch if determinant is close to zero

    # Proceed with calculations for x, y, z
    # Determinant_x, Determinant_y, Determinant_z can be calculated similarly
    # Omitted for brevity.

    # Print solutions
    li $v0, 2                    # Floating-point print syscall
    mov.s $f12, $f13             # Move solution into $f12 for print
    syscall

    # Exit
    li $v0, 10                   # Exit syscall
    syscall


error_division_by_zero:
    li $v0, 4
    la $a0, zero_determinant_msg
    syscall
    

# Jump back to main
    j main
exit:
    # Exit program
    li $v0, 10
    syscall
