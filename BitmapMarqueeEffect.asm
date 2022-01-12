# Mansi Patel
# 10/12/21
# Homework 4: Bitmap
# The program emulates a marquee affect using memory mapped I/O. 
# Instructions: Press assemble. Open Tools > Bitmap Display. Set pixel dim to 4x4 and set display dim to 256x256,
# Base address for display: $gp and press connect to MIPS. Open Tools > Keyboard and Display MMIO Simulator.
# Connect to MIPS. Press run.

# Register Key:
# $t7 = holds color (hex code) located at the address in $a2
# $t8 = address in $s3 (last color) + constant 4
# $t9 = holds calculated address based off of X and Y coordinates and $gp
# $s0 = max pixels for one line (7)
# $s1 = i = loop control variable for draw_box subroutine
# $s2 = address of color that draw_box is starting with (i.e. pink when drawing the box the first time, red the second time, etc.)
# $s3 = address of the index for the last color PURPLE in colors array
# $s4 = temporary "variable" to hold address of current color in $a2
# $s5 = holds starting position of X when moving and drawing a box
# $s6 = holds starting position of Y when moving and drawing a box
# $s7 = i = loop control variable for draw_black subroutine
# $a0 = constant 5 for delay syscall (occurs each time a pixel is drawn)
# $a1 = HEIGHT = Y coordinate
# $a2 = address of color for a pixel (each pixel in a line will be a different color, 
#       $a2 holds the address of each color as we iterate through each pixel)
# $a3 = WIDTH = X coordinate

# Width and height of screen in pixels
# Assembler goes through program and replaces any place that
# has WIDTH with the number 64
.eqv WIDTH 64
# Assembler goes through program and replaces any place that
# has HEIGHT with the number 64
.eqv HEIGHT 64

# Colors of pixels
# Please note that these colors are lighter versions of the name 
# (i.e. Red has a light shade of red)
.eqv	PINK	0x00FF66FF
.eqv	RED	0x00FF9999
.eqv	ORANGE	0x00FFCC99
.eqv	YELLOW	0x00FFFFCC
.eqv	MINT	0x00CCFF99
.eqv	BLUE	0x0099FFFF
.eqv	PURPLE	0x00CCCCFF
.eqv	BLACK	0x00000000

.data
# Colors array for draw_box to iterate through for the starting color each time the box is drawn
# and for each pixel in a line
colors:	.word	PINK, RED, ORANGE, YELLOW, MINT, BLUE, PURPLE
# Memory location for the color black, "BLACK" will be replaced with hex code for the color (all 0s)
black:	.word	BLACK


.text
main:
	# Load in 7 into $s7 register (number of pixels for each side)
	li	$s0, 7
	# Load starting address of colors array into register $s2
	# $s2 will contain the starting address of array colors
	la	$s2, colors
	# Load address of last color PURPLE into register $s3
	la	$s3, 24($s2)
	# $t8 = sum of address in $s3 and constant 4 (provides out of bounds address for array of colors)
	addi	$t8, $s3, 4
	
	# Set up a starting position
	# Starting position for width (roughly in center)
	# Note that register $a3 is used here instead of $a0 as $a0 is used for delay syscall
	addi	$a3, $zero, WIDTH	# a3 = X = WIDTH
	sra	$a3, $a3, 1		# a3 = a3/2 = WIDTH/2
	# Starting position for height (roughly in center)
	addi	$a1, $zero, HEIGHT	# a1 = Y = HEIGHT
	sra	$a1, $a1, 1		# a1 = a1/2 = HEIGHT/2
	
	# Two registers to hold starting position of X from $a3 and starting position of Y from $a1
	# These registers will be modified based on the direction we are moving the box in.
	move	$s5, $a3		# $s5 = $a3 = position of X		
	move 	$s6, $a1		# $s6 = $a1 = position of Y
	
infinite_loop:	
	# Jump to draw_box routine
	jal	draw_box
	
	# If address in $s2 is equal to the out of bounds address in $t8, jump to done_colors
	# as we have iterated through all starting colors in array of colors
	beq	$s2, $t8, done_colors
	
	# Check for input
	lw	$t0, 0xffff0000
	# If no input, keep displaying the box as is
	beq	$t0, 0, infinite_loop
	
	# Process input
	lw	$s1, 0xffff0004
	# If input is space, go to exit	
	beq	$s1, 32, exit
	# If input is up (w), branch to go_up
	beq	$s1, 119, go_up
	# If input is down (s), branch to go_down
	beq	$s1, 115, go_down
	# If input is left (a), branch to go_left
	beq	$s1, 97, go_left
	# If right (d), branch to go_right
	beq	$s1, 100, go_right
	# Invalid input, so loop again
	j	infinite_loop	

done_colors:
	la	$s2, colors		# We have iterated through the array of colors, so we start at the first color again
	j	infinite_loop		# Loop again

go_up:
	# If up (w): add -1 to starting position of Y ($s6), X stays the same ($s5)
	# Black out the box of pixels
	jal	draw_black
	# Add 1 to $s6, which contains the starting position of Y, to move 1 pixel up
	addi	$s6, $s6, -1
	# We want to continue our outer infinite loop and draw a new box
	j	infinite_loop
	
go_down:
	# If down (s): add 1 to starting position of Y ($s6), X stays the same ($s5)
	# Black out the current box of pixels
	jal	draw_black
	# Add -1 to $s6, which contains the starting position of Y, to move 1 pixel down
	addi	$s6, $s6, 1
	# We want to continue our outer infinite loop and draw a new box
	j 	infinite_loop

go_left:
	# If left (a): add -1 to starting position of X ($s5), Y stays the same ($s6)
	# Black out the current box of pixels
	jal	draw_black
	# Add -1 to $s5, which contains the starting position of X, to move 1 pixel left
	addi 	$s5, $s5, -1
	# We want to continue our outer infinite loop and draw a new box
	j 	infinite_loop

go_right:
	# If right (d): add 1 to starting position of X ($s5), Y stays the same ($s6)
	# Black out the current box of pixels
	jal	draw_black
	# Add 1 to $s5, which contains the starting position of X, to move 1 pixel right
	addi	$s5, $s5, 1
	# We want to continue our outer infinite loop and draw a new box
	j 	infinite_loop

	
exit:
	# Exit the program
	li	$v0, 10
	syscall
	
###################################################################
# Function to draw box of pixels with only black
draw_black:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_black instruction
	# in given branch
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s7, $zero, 0			# $s7 = i = 0 = loop counter variable
	la	$a2, black			# $a2 = address of memory location for black
	# Move updated starting coordinates that are in $s5 and $s6 into $a3 and $a1, the box will be
	# drawn based off of that starting coordinate
	move	$a3, $s5			# $a3 = X starting coordinate
	move 	$a1, $s6			# $a1 = Y starting coordinate
draw_black_top:
	bge 	$s7, $s0, done_black_top	# If i >= 7, go to done_black_top to reset i
	jal	draw_pixel			# Black out the pixel
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s7, $s7, 1			# Add 1 to i to increment loop counter
	j	draw_black_top			# Loop again
done_black_top:
	addi	$s7, $zero, 0			# Set i to 0 again before moving to next line
	j	draw_black_right		# Now we are ready to move to draw_black_right


draw_black_right:
	bge 	$s7, $s0, done_black_right	# If i >= 7, go to done__black_right to reset i
	jal	draw_pixel			# Black out the pixel
	addi	$a1, $a1, 1			# Add 1 to Y to move one spot down
	addi	$s7, $s7, 1			# Add 1 to i to increment loop counter
	j	draw_black_right		# Loop again
done_black_right:
	addi	$s7, $zero, 0			# Set i to 0 again before moving to next line
	j	draw_black_bottom		# Now we are ready to move to draw_black_bottom


draw_black_bottom:
	bge 	$s7, $s0, done_black_bottom	# If i >= 7, go to done__black_bottom to reset i
	jal	draw_pixel			# Black out the pixel
	addi	$a3, $a3, -1			# Add -1 to X to move left one position
	addi	$s7, $s7, 1			# Add 1 to i to increment loop counter
	j	draw_black_bottom		# Loop again
done_black_bottom:
	addi	$s7, $zero, 0			# Set i to 0 again before moving to next line
	j	draw_black_left			# Now we are ready to move to draw_black_left


draw_black_left:
	bge 	$s7, $s0, done_black_box	# If i >= 7, go to done_black_box as we have blacked out the whole box.
	jal	draw_pixel			# Black out the pixel
	addi	$a1, $a1, -1			# Add -1 to Y to move up one position
	addi	$s7, $s7, 1			# Add 1 to i to increment loop counter
	j	draw_black_left			# Loop again

done_black_box:
	# We have completed the black box. 
	# Pop $ra off the stack to jump back to draw_black function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
####################################################################
# Function to draw box of pixels with changing colors
draw_box:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_box instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s1, $zero, 0		# $s1 = i = 0 loop counter variable (used for all four lines of box)
	add	$a2, $zero, $s2		# a2 = address of starting color (which is in $s2)
	# Move updated starting coordinates that are in $s5 and $s6 into $a3 and $a1, the box will be
	# drawn based off of that starting coordinate
	move	$a3, $s5		# $a3 = X starting coordinate
	move 	$a1, $s6		# $a1 = Y starting coordinate
draw_top:
	# Draw 7 pixels for the top row
	add	$s4, $a2, $zero		# $s4 will hold address of color in $a2 temporarily
	bge 	$s1, $s0, done_top	# If i >= 7, go to done_top to reset i
	la	$a2, black		# Store the address of the color black into $a2
	jal	draw_pixel		# Draw the pixel in black
	move	$a2, $s4		# Move in the address of the intended color from $s4 into $a2
	jal	draw_pixel		# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1		# Add 1 to X to move right one position
	# If color address in $a2 is equal to the address of the last color in $s3, go to top_colors to reset
	beq	$a2, $s3, top_colors
	addi	$a2, $a2, 4		# Otherwise, move to next array element in array of colors
	addi	$s1, $s1, 1		# Add 1 to i to increment loop counter
	j	draw_top		# Loop again
top_colors:
	la	$a2, colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s1, $s1, 1		# Increment i to move to next pixel
	j draw_top			# Loop again
done_top:
	addi	$s1, $zero, 0		# Set i to 0 again before moving to next line
	j	draw_right		# Now we are ready to move to draw_right
	
	
draw_right:
	# Draw 7 pixels for right column
	add	$s4, $a2, $zero		# $s4 will have address of color in $a2 temporarily
	bge 	$s1, $s0, done_right	# If i >= 7, go to done_right to reset i to 0
	la	$a2, black		# Store the address of the color black into $a2
	jal	draw_pixel		# Draw the pixel with the color black
	move	$a2, $s4		# Move in the address of the intended color into $a2
	jal	draw_pixel		# Draw the pixel now with the new color
	addi	$a1, $a1, 1		# Add 1 to Y to move one spot down
	# If color address in $a2 is equal to the address of the last color in $s3, go to right_colors to reset
	beq	$a2, $s3, right_colors
	addi	$a2, $a2, 4		# Move to next array element in array of colors
	addi	$s1, $s1, 1		# Increment i before looping again
	j	draw_right
right_colors:
	la	$a2, colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s1, $s1, 1		# Increment i to move to next pixel
	j 	draw_right		# Loop again w/ starting color list over
done_right:
	addi	$s1, $zero, 0		# Set i to 0 again
	j	draw_bottom		# Now we are ready to move to draw_bottom
	
	
draw_bottom:
	# Draw 7 pixels for bottom row. We are moving backwards in this row!
	add	$s4, $a2, $zero		# $s4 will have address of color in $a2 temporarily
	bge 	$s1, $s0, done_bottom	# If i >= 7, go to done to reset i 
	la	$a2, black		# Store the address of the color black into $a2
	jal	draw_pixel		# Draw the pixel in black
	move	$a2, $s4		# Move in the address of the intended color from $s4 into $a2
	jal	draw_pixel
	addi	$a3, $a3, -1		# Add -1 to X to move left one position
	# If color address in $a2 is equal to the address of the last color in $s3, go to bottom_colors to reset
	beq	$a2, $s3, bottom_colors	# if $a2 = $s3, move to bottom colors to reset the colors
	addi	$a2, $a2, 4		# Move to next array element in array of colors
	addi	$s1, $s1, 1		# Add 1 to i to increment loop counter
	j	draw_bottom		# Loop again
bottom_colors:
	la	$a2, colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s1, $s1, 1		# Increment i to move to next pixel
	j	draw_bottom		# Loop again w/ starting list over
done_bottom:
	addi	$s1, $zero, 0		# Set i to 0 again
	j	draw_left		# Now we are ready to move to draw_left
	
	
draw_left:
	# Draw the left column to complete the box. We are moving backwards up this column!
	add	$s4, $a2, $zero		# $s4 will have address of color in $a2 temporarily
	bge 	$s1, $s0, done_box	# If i >= 7, go to done_box as we completed the full box
	la	$a2, black		# Store the address of the color black into $a2
	jal	draw_pixel		# Draw the pixel in black
	move	$a2, $s4		# Move in the address of the color from $s4 into $a2
	jal	draw_pixel		# Draw the pixel with the new color
	addi	$a1, $a1, -1		# Add -1 to Y to move up one position
	# If color address in $a2 is equal to the address of the last color in $s3, go to left_colors to reset
	beq	$a2, $s3, left_colors
	addi	$a2, $a2, 4		# Move to next array element in array of colors
	addi	$s1, $s1, 1		# Increment i
	j 	draw_left		# Loop again
left_colors:
	la	$a2, colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s1, $s1, 1		# Increment i to move to next pixel
	j 	draw_left		# Loop again w/ starting list over
	
done_box:
	# We've completed drawing our box so we can jump back to the beginning of the function again.
	# Move to next color in the color list by adding 4 to address in $s2, that color becomes starting color for the box
	addi	$s2, $s2, 4		# $s2 = address of updated starting color
	# Pop $ra off the stack to jump back to draw_box function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra

########################################################################
# Function to draw a pixel
draw_pixel:
	lw	$t7, ($a2)		# Load color that is located at address in $a2 into $t7
	mul	$t9, $a1, WIDTH		# $t9 = Y * WIDTH = Y * 64
	add	$t9, $t9, $a3		# $t9 = X + (Y * WIDTH)
	mul 	$t9, $t9, 4		# $t9 = $t9 * 4 for word offset
	add	$t9, $t9, $gp		# $t9 = $t9 + $gp, add address of $gp base address to $t9 
	sw	$t7, ($t9)		# Store color at calculated address
	# Delay of 5 ms
	li	$a0, 5
	li	$v0, 32
	syscall
	# Jump back to function call in specific draw_box branch
	jr $ra
######################################################################


	
