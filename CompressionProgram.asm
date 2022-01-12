# Mansi Patel
# HW 5: Compression
# 11/10/21
# This program will open a file, read a file, close
# a file, compress the file contents, and uncompress
# the file contents while utilizing macros.

.include	"HW5_macros.asm"

.data
# Memory location for error message
error_msg:		.asciiz	"Error: File could not be opened."
# Memory location for original file size
num_original_bytes:	.word	0
# Memory location for compressed file size
num_compressed_bytes:	.word	0

.text
main:

main_loop:

	# Call the get_str macro which will output a dialog box for the
	# user to input the file name.
	get_str
	
	# If user clicks cancel or enters a blank string, go to exit. 
	# $a1 = the status value of the dialog box, $t0 = status value for "Cancel" in Syscall 54,
	# $t1 = status value for "Ok" with no input in Syscall 54.
	beq	$a1, $t0, exit
	beq	$a1, $t1, exit
	
	# Print the file name
	print_str_literal("\n")
	print_str_literal("File Name: ")
	print_str($a3)
	print_str_literal("\n")
	# Open the file ($a3 = address of input file name string)
	open_file($a3)
	
	# If $s6 (contains file descriptor) is 0, print an error message.
	blt	$s6, $zero, print_error
	
	# Read the file into an input buffer space of 1024 bytes by calling
	# the read_file macro.
	read_file
	
	# Close the file using the $s6 (contains file descriptor) register. 
	close_file($s6)
	
	print_str_literal("\n")
	# Print the original data to the console using the print_str macro.
	# $a1 = base address of the input buffer
	print_str_literal("Original data: ")
	print_str_literal("\n")
	print_str($a1)
	print_str_literal("\n")
	
	# Move address in $a1 into temp register $t7 for later use
	move	$t7, $a1
	# Count the number of bytes in original data.
	# $a1 = base address of input buffer
	jal	count_original_data
	# Save the size of the original data in memory.
	sw	$v0, num_original_bytes
	
	
	# Allocate heap memory of 1024 bytes by calling the heap_allocate macro.
	heap_allocate

	# Set $a1 to the address of the compression buffer (which is in $v0 due to heap_allocate 
	# macro called previously).
	move	$a1, $v0
	# Set $a2 to the original file size.
	lw	$a2, num_original_bytes
	# Move contents of $t7, which contains base address of input buffer, into $a0
	move	$a0, $t7
	
	# Call the compression function
	jal	compression_function
	
	# Save the size of compressed data in memory
	sw	$v0, num_compressed_bytes
	
	# Move base address of heap memory in $v1 (which was stored
	# in compression_function function) into $a0
	move	$a0, $v1
	# Moved heap memory base address in $a0 into $t4 for later use
	move	$t4, $a0
	
	# Call a function to print the compressed data.
	print_str_literal("Compressed data: ")
	print_str_literal("\n")
	# Move base address of heap memory in $t4 into $a0
	move	$a0, $t4
	jal	print_function

	
	# Call the uncompress function to print uncompressed data to the console.
	print_str_literal("\n")
	print_str_literal("Uncompressed data: ")
	print_str_literal("\n")
	# Move the heap memory base address in $t4 into $a1.
	move	$a1, $t4
	jal	uncompress_function
	
	# Print new line 
	print_str_literal("\n")
	# Print the number of bytes in the original and compressed data
	print_str_literal("Original file size: ")
	print_int(num_original_bytes)
	print_str_literal("\n")
	print_str_literal("Compressed file size: ")
	print_int(num_compressed_bytes)
	# Print new line to separate different file outputs
	print_str_literal("\n")
	
	# If the user doesn't exit or enter a blank string for input, loop again
	j	main_loop

print_error:
	# If the file could not be opened, print an error message and end the program.
	li	$v0, 4
	la	$a0, error_msg
	syscall
	j 	exit

exit:
	# Exit the program.
	li	$v0, 10
	syscall

#####################################################################
# Uncompress the compressed data function
uncompress_function:
	# base address of heap memory in $a1 goes into $s7
	move	$s7, $a1
	# Integer holder
	li	$s5, 0
	# $t2 = 0 = inner loop control variable i 
	li	$t2, 0
	# $t3 = number of original bytes
	lw	$t3, num_original_bytes
	# $t9 = 0 = outer loop control variable j
	li	$t9, 0
outer_loop:
	lw	$t1, ($s7)			# $t1 will hold the character
	move	$s3, $s7			# Store address of character from $s7 into $s3
	bge	$t9, $t3, done_uncompress	# If $t9 == total original byte count, we have printed all uncompressed original characters
	addi	$s7, $s7, 4			# Add 4 to move to next index in compression buffer for count
	lw	$s5, ($s7)			# Store integer count of character at address into $s5
inner_loop:
	bge	$t2, $s5, done_inner		# if i >= integer count, go to done_inner
	print_char($s3)				# Otherwise, print the character
	addi	$t2, $t2, 1			# Increment i
	addi	$t9, $t9, 1			# Increment j
	j	inner_loop			# Loop again for inner loop
done_inner:
	# Add 4 to move to next index in compression buffer
	addi	$s7, $s7, 4
	# Reset i for inner loop
	addi	$t2, $zero, 0
	# Loop again for outer loop
	j	outer_loop
done_uncompress:
	jr	$ra
#####################################################################
# Print function
print_function:
	# $a0 has base address of heap memory
	move	$t5, $a0
	# $t9 = 0 = loop control variable
	li	$t9, 0
print_loop:
	# Print character $t5
	print_char($t5)
	# Add 4 to $t5
	addi	$t5, $t5, 4
	# Load int in $t5 into $t8
	lw	$t8, ($t5)
	# Print integer
	print_int_register($t8)
	# Add 4 to $t5
	addi	$t5, $t5, 4
	# Add 1 to i
	addi	$t9, $t9, 1
	# If $t9 == $s3 (total count for all individual characters), then we're done
	beq	$t9, $s3, done_printing
	j	print_loop
done_printing:
	jr	$ra
####################################################################
# Original data counter function
count_original_data:
	li	$s1, 0			# $s1 = will hold total number of bytes for original string
	move	$s2, $a1		# Move address of original string from $a1 into $s2
count_data_loop:
	lb	$t6, ($s2)		# $t6 = string[i], $a3 holds address of string
	beq	$t6, $zero, done_count	# If string[i] == 0, the string has been completely iterated through
	addi	$s1, $s1, 1		# Add one to byte counter for each character
	addi	$s2, $s2, 1		# If we have not completed the string, add 1 to address to move to next character
	j	count_data_loop		# Loop again
done_count:
	move	$v0, $s1		# Move total count in $s1 into $v0 before returning to function call
	jr	$ra
######################################################################
# Compress the original data and count the number of compressed bytes function
compression_function:
	# $a0 = base address of original string (input buffer)
	# $a1 = base address of compressed buffer in heap memory
	li	$t1, 0			# $t1 = 0 = counter for occurences of a character
	li	$s3, 0			# $s3 = 0 = counter for total characters in file
	li	$s5, 0			# $s5 = 0 = counter for number of bytes in compressed file
	li	$s7, 0			# $s7 = 0 = counter for new lines in compressed file
	# Move base address of compressed buffer into $v1 for later use
	move	$v1, $a1	
compress_loop:
	# Store character at address in $a0 into $t2, this will be the previous character.
	lb	$t2, ($a0)
	# Store character at address in $a0 + 1 into $t3, this will be the current character. 
	lb	$t3, 1($a0)
	# Increment occurence counter for character.
	addi	$t1, $t1, 1
	# if we encounter a new line character, the new line counter must be incremented.
	beq	$t3, 10, increment_new_line
	# If previous character != current_character, branch to new character as we are encountering 
	# another character (no longer repeating).	
	bne	$t2, $t3, new_character	
	# If current character == 0, we have fully iterated through the input buffer.	
	beq	$t3, $zero, done_compress
	# Add 1 to $a0 to move to next index in input buffer.		
	addi	$a0, $a0, 1
	# Loop again.
	j	compress_loop
increment_new_line:	
	# Increment new line counter
	addi	$s7, $s7, 1
new_character:
	# If we have encountered a new character, store the previous
	# character into the compression buffer.
	sw	$t2, ($a1)
	# Add 4 to $a1 to move to next index in compression buffer
	addi	$a1, $a1, 4
	# Store occurrence count into compression buffer
	sw	$t1, ($a1)
	# Count number of digits in occurrence count by calling the
	# count_number_of_digits macro.
	count_number_of_digits($t1)
	# Add number of digits in that count to total compressed byte count
	add	$s5, $s5, $s4
	# Add 1 more to $s5 to account for character associated with the occurrence count.
	addi	$s5, $s5, 1
	# The old current character in $t3 becomes the previous character that we compare a new current character with.
	move	$t2, $t3
	# Add 1 to $a0 to move to next index in input buffer.
	addi	$a0, $a0, 1
	# Add 4 to $a1 to move to next word
	addi	$a1, $a1, 4
	# Set $t1 occurrence counter back to 0.
	addi	$t1, $zero, 0
	# Add 1 to $s3 since we're encountering an individual (does not include
	# repetition) character in the buffer
	addi	$s3, $s3, 1
	# Loop again
	j	compress_loop
done_compress:
	# $v0 = $s5 - $s7 = number of compressed bytes - number of new line characters
	# $v0 will contain the total compressed byte count without new line characters.
	sub	$v0, $s5, $s7
	jr	$ra
	
