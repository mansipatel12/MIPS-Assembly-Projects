# Mansi Patel
# 11/12/21
# Macro File
# This file includes macros to print an int, print a char, print a string, get a string
# from the user, open file, close file, read file, and allocate heap memory

# Print an integer literal
.macro print_int (%x)
	.text
	lw 	$a0, %x
	li 	$v0, 1
	syscall
.end_macro

# Print an integer that has been loaded into a 
# register
.macro print_int_register ($x)
	move 	$a0, $x
	li 	$v0, 1
	syscall
.end_macro

# Print a character using an address that is stored
# in a register
.macro print_char ($x)
	lb	$a0, ($x)
	li	$v0, 11
	syscall
.end_macro

# Print a string literal
.macro print_str_literal (%str)
	.data
	# Memory location for passed in string literal
	macro_str:	.asciiz %str
	
	.text
	li	$v0, 4
	la	$a0, macro_str
	syscall
.end_macro

# Print a string using its address that is stored in a register
.macro print_str ($x)
	.text
	li	$v0, 4
	move	$a0, $x
	syscall
.end_macro

# Get the file name from the user
.macro get_str
	.data
	# Memory location for prompt
	name_prompt:	.asciiz	"Please enter the file name to compress or click cancel to exit: "
	# Memory location for input file name
	input_str:	.space	50
	
	.text
	# Load registers
	li	$t0, -2		# $t0 = status value for "Cancel" in Syscall 54
	li	$t1, -3 	# $t1 = status value for "Ok" with no input in Syscall 54

	# Use the dialog syscall (#54) to display prompt window and get input string from the user
	la	$a0, name_prompt	# $a0 = user input prompt
	li 	$v0, 54
	la	$a1, input_str		# $a1 = status value of input (value based on whether user inputs a string, cancels, or enters blank)
	li	$a2, 50			# $a2 = 50 is maximum number of characters to read
	syscall
	
	# Remove new line
	addi	$t3, $a2, 1	# $t3 = 51, which is the maximum number of characters to be read in $a2 + 1 (includes null terminator)
	li	$t4, 0		# $t4 serves as an index register; i = 0
	
inner_loop:
	# Loop through input string and remove the new line character at the end
	beq	$t4, $t3, done			# If i = 51, we have reached the maximum length of input (51) and must branch to done		
	lb	$t2, input_str($t4)		# Otherwise, load the character at index in $t4 of input_str into $t2
	beq	$t2, 10, remove_new_line	# If the character in $t2 equals the null terminator (line feed) character, branch to remove_new_line
	addi	$t4, $t4, 1			# Otherwise, add 1 to i (loop control)
	j	inner_loop			# Loop again
	
remove_new_line:
	# We have encountered the line feed (new line) character 
	# and must replace it with null
	sb	$0, input_str($t4)		
	j done
done:
	# Load input string into $a3 to use
	la	$a3, input_str
.end_macro

# Open file by passing in a register containing address of input file name
.macro open_file ($x)
	.text
	li	$v0, 13		# Syscall for open file
	move	$a0, $x
	li	$a1, 0		# Open for reading
	li	$a2, 0		# Mode is ignored
	syscall
	move	$s6, $v0	# Save file descriptor into $s6
.end_macro

# Close file
.macro	close_file (%x)
	li	$v0, 16		# syscall to close file
	move	$a0, $s6	
	syscall			# close file
.end_macro

# Read the file into an input buffer space of 1024 bytes
.macro	read_file
	.data
	read_input:	.space 1024
	
	.text
	la	$a1, read_input		# Load address of input into $a1
	reset_input_buffer($a1)		# Reset the input buffer to clear contents from previous files
	li	$v0, 14			# syscall for file read
	move	$a0, $s6		# $a0 now contains file descriptor
	la	$a1, read_input	
	li	$a2, 1024		# hardcoded buffer length
	syscall
.end_macro

# Allocate 1024 bytes of heap memory
.macro	heap_allocate
	li	$v0, 9		# syscall to allocate heap memory
	li	$a0, 1024	# Allocated 1024 bytes of dynamic memory
	syscall
.end_macro

# Count the number of digits in an integer value
.macro count_number_of_digits ($x)
	# $s4 = 1 = counter variable for number of digits
	li	$s4, 1
	# If statements to check if the number is <= 9, <= 99, <= 999, <= 9999
	ble	$x, 9, one_digit
	ble	$x, 99, two_digits
	ble	$x, 999, three_digits
	ble	$x, 9999, four_digits
one_digit:
	# If the integer is less than 9, it is one digit and
	# we are done counting.
	j	done_counting
two_digits:
	# If the integer is less than 99, it is two digits, so
	# add 1 to digit counter and branch to done counting.
	addi	$s4, $s4, 1
	j	done_counting
three_digits:
	# If the integer is less than 999, it is three digits, so
	# add 2 to digit counter and branch to done counting.
	addi	$s4, $s4, 2
	j	done_counting
four_digits:
	# If the integer is less than 9999, it is four digits, so
	# add 3 to digit counter and branch to done counting.
	addi	$s4, $s4, 3
	j	done_counting
done_counting:
.end_macro
	
# Reset the input buffer each time a new file is read in
# Input buffer address register will be passed in
.macro	reset_input_buffer ($x)
	li	$t3, 0		# $t3 = i = 0 (loop control variable)
loop:
	bgt	$t3, 1024, done	# Loop through the input buffer until i > 1024.
	sb	$zero, ($x)	# Store null into the current index address of input buffer.
	addi	$t3, $t3, 1	# Increment i
	addi	$x, $x, 1	# Add 1 to input buffer address register to move to next index
	j	loop		# Loop again
done:
.end_macro

