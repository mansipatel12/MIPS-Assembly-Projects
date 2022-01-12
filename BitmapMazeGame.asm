# Mansi Patel
# 10/24/21
# Bitmap Project

# Information about what the game does:
# The program emulates a Corn Maze game with Bitmap display and keyboard capabilities.

# Instructions about settings to set:
# Press assemble. Open Tools > Bitmap Display. Set pixel dim to 8x8 and set display dim to 512x512,
# Base address for display: $gp. Press connect to MIPS. Open Tools > Keyboard and Display MMIO Simulator.
# Connect to MIPS. Press run.

# Game rules:
# The red pixel in the bottom right corner represents the farmer pixel. Using the keyboard, the objective
# of the game is for the farmer to travel through the maze and find his tractor 
# without hitting any white pixels (representing ghosts).
# To move the farmer: press w for up, s for down, a for left, d for right
# To quit midgame, press space.

# Notes:
# Player has to try to get on top of the white pixels or tractor pixels for the 
# game to end, being right next to the specific pixel won't do anything.

# Register key:
# $s0 = holds contents of the address stored in $t8
# $s1 = maximum number pixels in a row in a given pixel box
# $s2 = starting address of border_colors color array
# $s3 = address of last index in border_colors color array
# $s4 = loop control variable for draw_small_box, draw_tractor_box, draw_maze_box, draw_top_border, draw_left_border, 
# draw_right_border, draw_bottom_border
# $s5 = holds address of intended color for pixel temporarily
# $s6 = loop control variable for draw_letter_vertical, draw_letter_horizontal, draw_horizontal, draw_vertical
# $s7 = holds the user input that is going to be processed
# $a0 = length of line of pixels to be drawn (horizontal maze piece lines, vertical maze piece lines, GAME OVER letter lines)
# $a1 = Y coordinate
# $a2 = color address of intended pixel
# $a3 = X coordinate
# $t1 = holds starting position of X (in $a3)
# $t2 = holds starting position of Y (in $a1)
# $t3 = starting X coordinate position (in $a3) for draw_letter_vertical, draw_vertical
# $t4 = starting Y coordinate position for draw_letter_horizontal, draw_horizontal
# $t6 = holds user input (if any)
# $t8 = holds calculated address of a given pixel using X and Y coordinates
# $t7 = holds color (hex code) located at the address in $a2
# $t9 = holds calculated address based off of X and Y coordinates and $gp

# Width and height of screen in pixels
# Assembler goes through program and replaces any place that
# has WIDTH with the number 512/8 = 128
.eqv WIDTH 64
# Assembler goes through program and replaces any place that
# has HEIGHT with the number 128
.eqv HEIGHT 64

# Colors of pixels
# Colors for outer borders
.eqv	YELLOW		0x00F0F090
.eqv	GREEN		0x0000CC00
# Color to fill in pixel initially
.eqv	BLACK		0x00000000
# Color for tractor icon
.eqv	TRACTOR_GREEN	0x00009900
.eqv	BLUE		0x00C0F0F2
# Color for farmer icon
.eqv	RED		0x00FF6666
# Color for ghost boxes
.eqv	WHITE		0x00FFFFFF

.data
# Colors array to iterate through when drawing outer borders
border_colors:	.word	YELLOW, GREEN
# Memory location for the color black, "BLACK" will be replaced with hex code for the color (all 0s)
black:		.word	BLACK
# Tractor colors
tractor_green:	.word	TRACTOR_GREEN
blue:		.word	BLUE
# Farmer color
red:		.word	RED
# Ghost color
white:		.word 	WHITE


.text
	# Load 64 into register $s1 (maximum number of pixels for each border line for the walls of game)
	li	$s1, 64
	# Load starting color of border_colors into $s2
	la	$s2, border_colors
	# Load address of last color in border_colors in $s3
	la	$s3, 4($s2)
	# Set up starting positions for X and Y (0, 0)
	add	$a3, $zero, $zero
	sra	$a3, $a3, 1
	add	$a1, $zero, $zero
	sra	$a1, $a1, 1
	
	# Draw outer walls of game
	# Call draw_top_border
	jal	draw_top_border
	# Call draw_left_border
	jal	draw_left_border
	# Call draw_bottom_border
	jal	draw_bottom_border
	# Call draw_right_border
	jal	draw_right_border
	
	# Create the tractor in the upper left corner of game
	# This 3x3 pixel box will have a top left starting coordinate of (6, 4)
	addi	$a3, $zero, 6
	addi	$a1, $zero, 4
	jal	draw_tractor_box
	# This 3x3 pixel box will have a top left starting coordinate of (5, 7)
	addi	$a3, $zero, 5
	addi	$a1, $zero, 7
	jal	draw_tractor_box
	# This 3x3 pixel box will have a top left starting coordinate of (8, 7)
	addi	$a3, $zero, 8
	addi	$a1, $zero, 7
	jal	draw_tractor_box
	# Draw small box in first tractor box (window of tractor)
	# Has a starting coordinate of (7,5)
	la	$a2, blue
	addi	$a3, $zero, 7
	addi	$a1, $zero, 5
	jal	draw_small_box
	
	# Draw horizontal maze pieces
	# Starting position is located in top left corner of each pixel
	# box drawn
	# 1) Line of length 5, starting position (3, 19)
	li	$a0, 5
	addi	$a3, $zero, 3
	addi	$a1, $zero, 19
	jal	draw_horizontal
	# 2) Line of length 3, starting position (16, 9)
	li	$a0, 3
	addi	$a3, $zero, 16
	addi	$a1, $zero, 9
	jal	draw_horizontal
	# 3) Line of length 2, starting position (12, 28)
	li	$a0, 2
	addi	$a3, $zero, 12
	addi	$a1, $zero, 28
	jal	draw_horizontal
	# 4) Line of length 2, starting position (12, 43)
	li	$a0, 2
	addi	$a3, $zero, 12
	addi	$a1, $zero, 43
	jal	draw_horizontal
	# 5) Line of length 5, starting position (3, 52)
	li	$a0, 3
	addi	$a3, $zero, 3
	addi	$a1, $zero, 52
	jal	draw_horizontal
	# 6) Line of length 6, starting position (21, 22)
	li	$a0, 6
	addi	$a3, $zero, 21
	addi	$a1, $zero, 22
	jal	draw_horizontal
	# 7) Line of length 4, starting position (21, 40)
	li	$a0, 4
	addi	$a3, $zero, 21
	addi	$a1, $zero, 40
	jal	draw_horizontal
	# 8) Line of length 2, starting position (30, 9)
	li	$a0, 2
	addi	$a3, $zero, 30
	addi	$a1, $zero, 9
	jal	draw_horizontal
	# 9) Line of length 3, starting position (39, 16)
	li	$a0, 3
	addi	$a3, $zero, 39
	addi	$a1, $zero, 16
	jal	draw_horizontal
	# 10) Line of length 3, starting position (33, 52)
	li	$a0, 3
	addi	$a3, $zero, 33
	addi	$a1, $zero, 52 
	jal	draw_horizontal
	# 11) Line of length 4, starting position (31, 32)
	li	$a0, 4
	addi	$a3, $zero, 31
	addi	$a1, $zero, 32
	jal	draw_horizontal
	# 12) Line of length 3, starting position (40, 35)
	li	$a0, 3
	addi	$a3, $zero, 40
	addi	$a1, $zero, 35
	jal	draw_horizontal
	# 13) Line of length 3, starting position (52, 26)
	li	$a0, 3
	addi	$a3, $zero, 52
	addi	$a1, $zero, 26
	jal	draw_horizontal
	# 14) Line of length 1, starting position (53, 9)
	li	$a0, 1
	addi	$a3, $zero, 53
	addi	$a1, $zero, 9
	jal	draw_horizontal
	# 15) Line of length 2, starting position (55, 19)
	li	$a0, 2
	addi	$a3, $zero, 55
	addi	$a1, $zero, 19
	jal	draw_horizontal
	
	# Draw vertical maze pieces
	# 1) Line of length 9, starting position (18, 18) 
	li	$a0, 9
	addi	$a3, $zero, 18
	addi	$a1, $zero, 18
	jal	draw_vertical
	# 2) Line of length 3, starting position (13, 2) 
	li	$a0, 3
	addi	$a3, $zero, 13
	addi	$a1, $zero, 2
	jal	draw_vertical
	# 3) Line of length 3, starting position (9, 27)
	li	$a0, 3
	addi	$a3, $zero, 9
	addi	$a1, $zero, 27
	jal	draw_vertical
	# 4) Line of length 3, starting position (18, 51)
	li	$a0, 3
	addi	$a3, $zero, 18
	addi	$a1, $zero, 51
	jal	draw_vertical
	# 5) Line of length 2, starting position (39, 18)
	li	$a0, 2
	addi	$a3, $zero, 39
	addi	$a1, $zero, 18
	jal	draw_vertical
	# 6) Line of length 4, starting position (30, 42)
	li	$a0, 4
	addi	$a3, $zero, 30
	addi	$a1, $zero, 42
	jal	draw_vertical
	# 7) Line of length 2, starting position (30, 2)
	li	$a0, 2
	addi	$a3, $zero, 30
	addi	$a1, $zero, 2
	jal	draw_vertical
	# 8) Line of length 8, starting position (49, 25)
	li	$a0, 8
	addi	$a3, $zero, 49
	addi	$a1, $zero, 25
	jal	draw_vertical
	# 9) Line of length 4, starting position (58, 28)
	li	$a0, 4
	addi	$a3, $zero, 58
	addi	$a1, $zero, 28
	jal	draw_vertical
	# 10) Line of length 2, starting position (41, 2)
	li	$a0, 2
	addi	$a3, $zero, 41
	addi	$a1, $zero, 2
	jal	draw_vertical
	# 11) Line of length 3, starting position (50, 2)
	li	$a0, 3
	addi	$a3, $zero, 50
	addi	$a1, $zero, 2
	jal	draw_vertical
	
	# Draw white ghost pixels (will be 2x2 boxes)
	# Starting position is top left corner of drawn pixel box
	# Load in color for all ghost pixels
	la	$a2, white
	# 1) Box at starting position (28, 32)
	addi	$a3, $zero, 28
	addi	$a1, $zero, 32
	jal	draw_small_box
	# 2) Box at starting position (24, 58)
	addi	$a3, $zero, 24
	addi	$a1, $zero, 58
	jal	draw_small_box
	# 3) Box at starting position (15, 25)
	addi	$a3, $zero, 15
	addi	$a1, $zero, 25
	jal	draw_small_box
	# 4) Box at starting position (4, 15)
	addi	$a3, $zero, 4
	addi	$a1, $zero, 15
	jal	draw_small_box
	# 5) Box at starting position (52, 19)
	addi	$a3, $zero, 52
	addi	$a1, $zero, 19
	jal	draw_small_box
	# 6) Box at starting position (42, 10)
	addi	$a3, $zero, 42
	addi	$a1, $zero, 10
	jal	draw_small_box
	
	# Draw initial farmer box: starting position of farmer is at top left coordinate of box (57, 57) 
	# Farmer box is located in bottom right corner of board
	la	$a2, red
	addi	$a3, $zero, 57
	addi	$a1, $zero, 57
	jal	draw_small_box
	
get_input:
	# Check for input in $t6
	lw	$t6, 0xffff0000
	# If no input, keep displaying the box as is
	beq	$t6, 0, get_input
	
	# Process input (loaded into $s7)
	lw	$s7, 0xffff0004
	# If input is space, go to exit	
	beq	$s7, 32, exit
	# If input is up (w), branch to go_up
	beq	$s7, 119, go_up
	# If input is down (s), branch to go_down
	beq	$s7, 115, go_down
	# If input is left (a), branch to go_left
	beq	$s7, 97, go_left
	# If right (d), branch to go_right
	beq	$s7, 100, go_right
	# If invalid input, loop again
	j 	get_input

go_up:
	# If up (w): add -1 to starting position of Y, X stays the same
	# We are going to check the pixel above our starting position before moving.
	addi	$a1, $a1, -1
	# Calculate offset (Y * 64) + X and add to $gp, store result in $t8
	mul	$t8, $a1, 64
	add	$t8, $t8, $a3
	# Shift $t8 by 2 ($t8 * 4) to align on word boundary
	sll	$t8, $t8, 2
	add	$t8, $t8, $gp
	# Load contents of $t8 into $s0
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_up
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_up
	beq	$s0, YELLOW, not_going_up
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# Add 4 to $t8 to check pixel on the right of top left corner pixel
	addi	$t8, $t8, 4
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_up
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_up
	beq	$s0, YELLOW, not_going_up
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	beq	$s0, WHITE, game_over
	# If we are doing branching above, black out the box of pixels in the original position
	addi	$a1, $a1, 1
	la	$a2, black
	jal	draw_small_box
	# Moving up, so add -1 to Y
	addi	$a1, $a1, -1
	# Load the address of red into $a2
	la	$a2, red
	# Call the draw_small_box function to redraw farmer pixel
	jal	draw_small_box
	# Wait for more input
	j	get_input
not_going_up:
	# Since we are going to hit a wall if we move up, restore the original starting
	# position of farmer and go back to get input to wait for more input.
	addi	$a1, $a1, 1	
	j	get_input
	
go_down:
	# Get bottom left corner position of farmer box by adding 1 to $a1 (Y)
	addi	$a1, $a1, 1
	# We are trying to check the pixel below the bottom pixel of farmer box before moving, 
	# so add 1 to $a1 again.
	addi	$a1, $a1, 1
	# Calculate offset (Y * 64) + X and add to $gp, stored in $t8
	mul	$t8, $a1, 64
	add	$t8, $t8, $a3
	# Shift $t8 by 2 ($t8 * 4) to align on word boundary
	sll	$t8, $t8, 2
	add	$t8, $t8, $gp
	# Load $t8 contents into $s0
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_down
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_down
	beq	$s0, YELLOW, not_going_down
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# Add 4 to $t8 to check pixel on the right of bottom left corner of farmer box
	addi	$t8, $t8, 4
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_down
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_down
	beq	$s0, YELLOW, not_going_down
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# If we are not branching above, black out the box of pixels in original starting position
	# Subtract 2 to get back to top left position.
	addi	$a1, $a1, -2
	la	$a2, black
	jal	draw_small_box
	# Add 1 to $a1, which now contains top left position of Y, to move 1 pixel down
	addi	$a1, $a1, 1
	# Load the address of red into $a2
	la	$a2, red
	# Call the draw_small_box function to redraw farmer pixel
	jal	draw_small_box
	# Wait for more input
	j	get_input
not_going_down:
	# Since we are going to hit a wall if we move down, 
	# subtract 2 to restore top left corner position of farmer box and wait
	# for more input.
	addi	$a1, $a1, -2
	j	get_input

go_left:
	# Add -1 to $a3, which contains the position of X, to move 1 pixel left
	# We are going to check the pixels to the left of the farmer box before moving.
	addi 	$a3, $a3, -1
	# Calculate offset (Y * 64) + X and add to $gp, store the result in $t8
	mul	$t8, $a1, 64
	add	$t8, $t8, $a3
	# Shift $t8 by 2 ($t8 * 4) to align on word boundary
	sll	$t8, $t8, 2
	add	$t8, $t8, $gp
	# Load $t8 contents into $s0
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_left
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_left
	beq	$s0, YELLOW, not_going_left
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# Add 256 to $t8 to check pixel below (64 to get to pixel directly below * 4 for each spot)
	addi	$t8, $t8, 256
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_left
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_left
	beq	$s0, YELLOW, not_going_left
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# If we are not branching above, black out the box of pixels in original top left (starting) position
	addi 	$a3, $a3, 1
	la	$a2, black
	jal	draw_small_box
	# Add -1 to $a3, which contains the position of X, to move 1 pixel left
	addi 	$a3, $a3, -1
	# Load the address of red into $a2
	la	$a2, red
	# Call the draw_small_box function to redraw farmer pixel
	jal	draw_small_box
	# Wait for more input
	j	get_input
not_going_left:
	# Since we are going to hit a wall if we move left, 
	# add 1 to $a3 to restore original starting position and wait for more input.
	addi 	$a3, $a3, 1
	j	get_input

go_right:
	# Get top right position of farmer box by adding 1 to $a3 ($a3 holds top left position of farmer box, then added to 1)
	addi	$a3, $a3, 1
	# Moving right, so add 1 to $a3 (X). We want to check the pixels to the right of the farmer box before moving.
	addi	$a3, $a3, 1
	# Calculate offset (Y * 64) + X and add to $gp, store the result in $t8
	mul	$t8, $a1, 64
	add	$t8, $t8, $a3
	# Shift $t8 by 2 ($t8 * 4) to align on word boundary
	sll	$t8, $t8, 2
	add	$t8, $t8, $gp
	# Load $t8 contents into $s0
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_right
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_right
	beq	$s0, YELLOW, not_going_right
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# Add 256 to $t8 to check pixel below (64 to get to pixel below * 4 for each spot)
	addi	$t8, $t8, 256
	lw	$s0, ($t8)
	# If the pixel at the calculated offset is green or yellow, go to not_going_right
	# This means we are going to hit a wall.
	beq	$s0, GREEN, not_going_right
	beq	$s0, YELLOW, not_going_right
	# If the pixel is tractor green, go to game_over as player won
	beq	$s0, TRACTOR_GREEN, game_over
	# If the pixel is white, go to game_over as player lost (bumped into a ghost)
	beq	$s0, WHITE, game_over
	# Black out the box of pixels in original position (subtract 2 from $a3 to restore top left starting position)
	addi	$a3, $a3, -2
	la	$a2, black
	jal	draw_small_box
	# Add 1 to $a3, which contains the position of X, to move 1 pixel right
	addi	$a3, $a3, 1
	# Load the address of red into $a2
	la	$a2, red
	# Call the draw_small_box function to redraw farmer pixel
	jal	draw_small_box
	# Wait for more input
	j	get_input
not_going_right:
	# Since we are going to hit a wall if we move right, subtract 2 from $a3 
	# to restore top left corner position and wait for more input.
	addi	$a3, $a3, -2
	j get_input
	
game_over:
	# The tractor has been found or we bumped into a ghost, so draw
	# GAME OVER in pixels.

	# Draw the letter G
	# 1) Draw vertical line of length 8, starting position (5, 14)
	li	$a0, 8
	addi	$a3, $zero, 5
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 2) Draw horizontal line of length 4, starting position (7, 16)
	li	$a0, 4
	addi	$a3, $zero, 7
	addi	$a1, $zero, 16
	jal	draw_letter_horizontal
	# 3) Draw horizontal line of length 4, starting position (7, 30)
	li	$a0, 4
	addi	$a3, $zero, 7
	addi	$a1, $zero, 30
	jal	draw_letter_horizontal
	# 4) Draw vertical line of length 3, starting position (15, 23)
	li	$a0, 3
	addi	$a3, $zero, 15
	addi	$a1, $zero, 23
	jal	draw_letter_vertical
	# 5) Draw horizontal line of length 2, starting position (11, 23)
	li	$a0, 2
	addi	$a3, $zero, 11
	addi	$a1, $zero, 23
	jal	draw_letter_horizontal
	
	# Draw letter A
	# 1) Draw vertical line of length 8, starting position (20, 14)
	li	$a0, 8
	addi	$a3, $zero, 20
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 2) Draw horizontal line of length 2, starting position (22, 16)
	li	$a0, 2
	addi	$a3, $zero, 22
	addi	$a1, $zero, 16
	jal	draw_letter_horizontal
	# 3) Draw vertical line of length 8, starting position (28, 14)
	li	$a0, 8
	addi	$a3, $zero, 28
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 4) Draw horizontal line of length 2, starting position (22, 22)
	li	$a0, 2
	addi	$a3, $zero, 22
	addi	$a1, $zero, 22
	jal	draw_letter_horizontal
	
	# Draw letter M
	# 1) Draw vertical line of length 8, starting position (33, 14)
	li	$a0, 8
	addi	$a3, $zero, 33
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 2) Draw vertical line of length 8, starting position (39, 14)
	li	$a0, 8
	addi	$a3, $zero, 39
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 3) Draw vertical line of length 8, starting position (45, 14)
	li	$a0, 8
	addi	$a3, $zero, 45
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 4) Draw horizontal line of length 6, starting position (33, 16)
	li	$a0, 6
	addi	$a3, $zero, 33
	addi	$a1, $zero, 16
	jal	draw_letter_horizontal
	
	# Draw letter E
	# 1) Draw vertical line of length 8, starting position (50, 14)
	li	$a0, 8
	addi	$a3, $zero, 50
	addi	$a1, $zero, 14
	jal	draw_letter_vertical
	# 2) Draw horizontal line of length 3, starting position (52, 16)
	li	$a0, 3
	addi	$a3, $zero, 52
	addi	$a1, $zero, 16
	jal	draw_letter_horizontal
	# 3) Draw horizontal line of length 3, starting position (52, 23)
	li	$a0, 3
	addi	$a3, $zero, 52
	addi	$a1, $zero, 23
	jal	draw_letter_horizontal
	# 4) Draw horizontal line of length 3, starting position (52, 30)
	li	$a0, 3
	addi	$a3, $zero, 52
	addi	$a1, $zero, 30
	jal	draw_letter_horizontal
	
	# Draw the letter O
	# 1) Draw vertical line of length 8, starting position (5, 33)
	li	$a0, 8
	addi	$a3, $zero, 5
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 2) Draw vertical line of length 8, starting position (15, 33)
	li	$a0, 8
	addi	$a3, $zero, 15
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 3) Draw horizontal line of length 4, starting position (5, 35)
	li	$a0, 4
	addi	$a3, $zero, 5
	addi	$a1, $zero, 35
	jal	draw_letter_horizontal
	# 4) Draw horizontal line of length 4, starting position (5, 49)
	li	$a0, 4
	addi	$a3, $zero, 5
	addi	$a1, $zero, 49
	jal	draw_letter_horizontal
	
	# Draw the letter V
	# 1) Draw vertical line of length 8, starting position (20, 33)
	li	$a0, 8
	addi	$a3, $zero, 20
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 2) Draw vertical line of length 8, starting position (28, 33)
	li	$a0, 8
	addi	$a3, $zero, 28
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 3) Draw horizontal line of length 4, starting position (20, 49)
	li	$a0, 4
	addi	$a3, $zero, 20
	addi	$a1, $zero, 49
	jal	draw_letter_horizontal
	
	# Draw letter E
	# 1) Draw vertical line of length 8, starting position (33, 33)
	li	$a0, 8
	addi	$a3, $zero, 33
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 2) Draw horizontal line of length 3, starting position (35, 35)
	li	$a0, 3
	addi	$a3, $zero, 35
	addi	$a1, $zero, 35
	jal	draw_letter_horizontal
	# 3) Draw horizontal line of length 3, starting position (35, 42)
	li	$a0, 3
	addi	$a3, $zero, 35
	addi	$a1, $zero, 42
	jal	draw_letter_horizontal
	# 4) Draw horizontal line of length 3, starting position (35, 49)
	li	$a0, 3
	addi	$a3, $zero, 35
	addi	$a1, $zero, 49
	jal	draw_letter_horizontal
	
	# Draw letter R
	# 1) Draw vertical line of length 8, starting position (47, 33)
	li	$a0, 8
	addi	$a3, $zero, 47
	addi	$a1, $zero, 33
	jal	draw_letter_vertical
	# 2) Draw horizontal line of length 3, starting at position (49, 35)
	li	$a0, 3
	addi	$a3, $zero, 49
	addi	$a1, $zero, 35
	jal	draw_letter_horizontal
	# 3) Draw horizontal line of length 3, starting at position (49, 43)
	li	$a0, 3
	addi	$a3, $zero, 49
	addi	$a1, $zero, 43
	jal	draw_letter_horizontal
	# 4) Draw vertical line of length 4, starting at position (55, 35)
	li	$a0, 4
	addi	$a3, $zero, 55
	addi	$a1, $zero, 35
	jal	draw_letter_vertical
	# 5) Draw vertical line of length 4, starting at position (57, 41)
	li	$a0, 4
	addi	$a3, $zero, 57
	addi	$a1, $zero, 41
	jal	draw_letter_vertical

	
exit:
	# Exit the program
	li	$v0, 10
	syscall

#######################################################################
# Draw vertical maze line function
draw_letter_vertical:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_letter_vertical instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s6, $zero, 0			# $s6 = i = 0 loop counter variable
	# Vertical lines for letter will be drawn in red, $a2 contains address
	la	$a2, red
	# Store top left x coordinate of first box (starting position 
	# as we go from left to right to draw line) into $t3
	move	$t3, $a3
draw_vertical_letter_loop:			
	bge	$s6, $a0, done_vertical_letter		# if i >= length in $a0, go to done_vertical_letter
	addi	$a1, $a1, 2				# add 2 to Y to move 2 positions down to draw the new box
	jal	draw_small_box				# call draw_small_box function
	add	$a3, $t3, $zero				# set $a3 to original starting position (which is in $t3)
	addi	$s6, $s6, 1				# increment i
	j	draw_vertical_letter_loop		# loop again
done_vertical_letter:
	# Pop $ra off the stack to jump back to draw_vertical_letter function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
#######################################################################
# Draw horizontal letter line function
draw_letter_horizontal:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_letter_horizontal instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s6, $zero, 0				# $s6 = i = 0 loop counter variable
	# Horizontal lines for letter will be drawn in red, $a2 contains address
	la	$a2, red
	# Store top left y coordinate of first box (starting position 
	# as we go from left to right to draw line)
	move	$t4, $a1
draw_horizontal_letter_loop:			
	bge	$s6, $a0, done_horizontal_letter	# if i >= length in $a0, go to done_horizontal_letter
	jal	draw_small_box				# call draw_small_box function
	add	$a1, $t4, $zero				# set $a1 to original starting position (which is in $t4)
	addi	$a3, $a3, 2				# add 2 to X to move 2 positions to the right to draw the new box
	addi	$s6, $s6, 1				# increment i
	j	draw_horizontal_letter_loop		# loop again
done_horizontal_letter:
	# Pop $ra off the stack to jump back to draw_horizontal_letter function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
########################################################################
# Draw smaller 2x2 box function (used for farmer and tractor window)
draw_small_box:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_small_box instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s1, $zero, 2			# Set $s1 (max number of pixels in a line) to 2
	addi	$s4, $zero, 0			# $s4 = i = 0 loop counter variable
	move	$t1, $a3			# $t1 = $a3 starting position
	move	$t2, $a1			# $t2 = $a1 starting position
draw_first_small_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, first_small_row	# If i >= 2, go to first_small_row to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_small_row		# Loop again
first_small_row:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $t1, 0			# Set $a3 (X) to original starting position
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row		
	j	draw_second_small_row		# Now we are ready to move to draw_second_small_row

draw_second_small_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_small_box	# If i >= 2, go to done_small_box
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_small_row		# Loop again

done_small_box:
	# Restore starting positions of X and Y
	move	$a3, $t1
	move	$a1, $t2
	# Pop $ra off the stack to jump back to draw_small_box function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
####################################################################
# Draw horizontal maze line function
draw_horizontal:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_horizontal instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s6, $zero, 0			# $s6 = i = 0 loop counter variable
	# Store top left y coordinate of first box (starting position 
	# as we go from left to right to draw line)
	move	$t4, $a1
draw_horizontal_loop:			
	bge	$s6, $a0, done_horizontal	# if i >= length in $a0, go to done_horizontal
	jal	draw_maze_box			# call draw_maze_box function
	add	$a1, $t4, $zero			# set $a1 to original starting position (which is in $t4)
	addi	$s6, $s6, 1			# increment i
	j	draw_horizontal_loop		# loop again
done_horizontal:
	# Pop $ra off the stack to jump back to draw_horizontal function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
#######################################################################
# Draw vertical maze line function
draw_vertical:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_vertical instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s6, $zero, 0			# $s6 = i = 0 loop counter variable
	# Store top left x coordinate of first box (starting position 
	# as we go from left to right to draw line)
	move	$t3, $a3
draw_vertical_loop:			
	bge	$s6, $a0, done_vertical		# if i >= length in $a0, go to done_vertical
	addi	$a1, $a1, 1			# add 1 to Y to move 1 position down to draw the new box
	jal	draw_maze_box			# call draw_maze_box function
	add	$a3, $t3, $zero			# set $a3 to original starting position (which is in $t3)
	addi	$s6, $s6, 1			# increment i
	j	draw_vertical_loop		# loop again
done_vertical:
	# Pop $ra off the stack to jump back to draw_vertical function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
######################################################################
# Draw tractor box function
# Creates a 3x3 box in blue for tractor
# The tractor remains in fixed position for entire game.
draw_tractor_box:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_tractor_box instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s1, $zero, 3			# Set $s1 (max number of pixels in a line) to 3
	addi	$s4, $zero, 0			# $s4 = i = 0 loop counter variable
	la	$a2, tractor_green		# Load address of tractor_green memory location into $a2
	move	$t1, $a3			# $t1 = $a3 starting position
	move	$t2, $a1			# $t2 = $a1 starting position
draw_first_tractor_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, first_tractor_row	# If i >= 3, go to first_tractor_row to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_tractor_row		# Loop again
first_tractor_row:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $t1, 0			# Set $a3 (X) to original starting position
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row		
	j	draw_second_tractor_row		# Now we are ready to move to draw_second_tractor_row

draw_second_tractor_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, second_tractor_row	# If i >= 3, go to second_tractor_row to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_tractor_row		# Loop again
second_tractor_row:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $t1, 0			# Set $a3 (X) to original starting position
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row
	j	draw_third_tractor_row		# Now we are ready to move to draw_third_tractor_row
	
draw_third_tractor_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_tractor_box	# If i >= 3, go to done_tractor_box as full box has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_tractor_row		# Loop again
	
done_tractor_box:
	# Pop $ra off the stack to jump back to draw_tractor_box function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
############################################################
# Function to draw a 3x3 box for maze pieces	
draw_maze_box:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_maze_box instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s1, $zero, 3			# Set $s1 (max number of pixels in a line) to 3
	addi	$s4, $zero, 0			# $s4 = i = 0 loop counter variable (used for all four lines of box)
	add	$a2, $zero, $s2			# a2 = address of starting color in border_colors array (which is in $s2)
	move	$t1, $a3			# $t1 = $a3 starting position
	move	$t2, $a1			# $t2 = $a1 starting position
draw_first_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_first_row	# If i >= 3, go to done_first_row to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, first_colors		# If address in $a2 equals address in $s3 (last color), go to first_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_row			# Loop again
first_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_first_row			# Loop again
done_first_row:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $t1, 0			# Set $a3 (X) to original starting position
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row
	move	$a2, $s3			# Move address of color in $s3 to $a2, this will become our new starting color (green)		
	j	draw_second_row			# Now we are ready to move to draw_second_row

draw_second_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_second_row	# If i >= 3, go to done_second_row to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, second_colors		# If address in $a2 equals address in $s3 (last color), go to second_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_row			# Loop again
second_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_second_row			# Loop again
done_second_row:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $t1, 0			# Set $a3 (X) to original starting position
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row
	move	$a2, $s2			# Move address in $s2 to $a2, this will become our new starting color for the line (yellow)		
	j	draw_third_row			# Now we are ready to move to draw_third_row
	
draw_third_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_maze_box		# If i >= 3, go to done_maze_box as the full box has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, third_colors		# If address in $a2 equals address in $s3 (last color), go to third_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_row			# Loop again
third_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_third_row			# Loop again
	
done_maze_box:
	# Pop $ra off the stack to jump back to draw_maze_box function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra	

######################################################################
# Function to draw TOP BORDER
# X will start with 0
# Y will start with 0
draw_top_border:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_top_border instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s4, $zero, 0			# $s4 = i = 0 loop counter variable (used for all four borders)
	add	$a2, $zero, $s2			# a2 = address of starting color (which is in $s2)
draw_first_top_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_first_top	# If i >= 64, go to done_first_top to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, first_top_colors	# If address in $a2 equals address in $s3 (last color), go to first_top_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_top_row		# Loop again
first_top_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_first_top_row		# Loop again
done_first_top:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $zero, 0			# Set $a3 (X) to 0 again
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row
	move	$a2, $s3			# Move address of color in $s3 to $a2, this will become our new starting color (green)		
	j	draw_second_top_row		# Now we are ready to move to draw_second_top_row

draw_second_top_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_second_top	# If i >= 64, go to done_second_top to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s4 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, second_top_colors	# If address in $a2 equals address in $s3 (last color), go to second_top_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_top_row		# Loop again
second_top_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_second_top_row		# Loop again
done_second_top:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $zero, 0			# Set $a3 (X) to 0 again
	addi	$a1, $a1, 1			# Add to 1 to $a1 (Y) to move down one row
	move	$a2, $s2			# Move address in $s2 to $a2, this will become our new starting color for the line (yellow)		
	j	draw_third_top_row		# Now we are ready to move to draw_third_top_row
	
draw_third_top_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_top		# If i >= 64, go to done_top as full border has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, third_top_colors	# If address in $a2 equals address in $s3 (last color), go to third_top_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_top_row		# Loop again
third_top_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_third_top_row		# Loop again
	
done_top:
	# Pop $ra off the stack to jump back to draw_top_border function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra	
########################################################################
# Function to draw LEFT BORDER
# X will start with 0
# Y will start with 0
draw_left_border:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_left_border instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s4, $zero, 0			# Set $s4 = i to 0 again 
	addi	$a3, $zero, 0			# Set $a3 = X coordinate to 0 again
	addi	$a1, $zero, 0			# Set $a1 = Y coordinate to 0 again
	add	$a2, $zero, $s2			# a2 = address of starting color yellow (which is in $s2) 
draw_first_left_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_first_left	# If i >= 64, go to done_first_left to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, first_left_colors	# If address in $a2 equals address in $s3 (last color), go to first_left_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_left_col		# Loop again
first_left_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_first_left_col		# Loop again
done_first_left:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $a3, 1			# Add 1 to $a3 (X) to move one position to the right from 0
	addi	$a1, $zero, 0			# Set $a1 (Y) to 0 again
	move	$a2, $s3			# Move address of last color in $s3 to $a2, this will become our new starting color (green)		
	j	draw_second_left_col		# Now we are ready to move to draw_second_left_col
	
draw_second_left_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_second_left 	# If i >= 64, go to done_second_left to reset and set certain registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, second_left_colors	# If address in $a2 equals address in $s3 (last color), go to second_left_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_left_col		# Loop again
second_left_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_second_left_col		# Loop again
done_second_left:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $a3, 1			# Add 1 to $a3 (X) to move another position to the right
	addi	$a1, $zero, 0			# Set $a1 (Y) to 0 again
	move	$a2, $s2			# Move address of starting color in $s2 to $a2, this will become our new starting color (yellow)		
	j	draw_third_left_col		# Now we are ready to move to draw_third_left_col
	
draw_third_left_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_left		# If i >= 64, go to done_left as the full border has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, third_left_colors	# If address in $a2 equals address in $s3 (last color), go to third_left_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_left_col		# Loop again
third_left_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_third_left_col		# Loop again
	
done_left:
	# Pop $ra off the stack to jump back to draw_left_border function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
########################################################################
# Function to draw BOTTOM BORDER
# Note that we start in the bottom left corner (0, 63) and work upwards for three rows.
# X will start with 0
# Y will start with 63 
draw_bottom_border:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_left_border instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s4, $zero, 0			# Set $s4 = i to 0 again 
	addi	$a3, $zero, 0			# Set $a3 = X coordinate to 0 again
	addi	$a1, $zero, 63			# Set $a1 = Y coordinate to 63
	add	$a2, $zero, $s3			# a2 = address of last color in border_colors array (which is in $s3) 
draw_first_bottom_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_first_bottom	# If i >= 64, go to done_first_bottom to set and reset registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, first_bottom_colors	# If address in $a2 equals address in $s3 (last color), go to first_bottom_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_bottom_row		# Loop again
first_bottom_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_first_bottom_row		# Loop again
done_first_bottom:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $zero, 0			# Set $a3 (X) to 0 again
	addi	$a1, $a1, -1			# Add to -1 to $a1 (Y) to move up one row
	move	$a2, $s2			# Move address of starting color in $s2 to $a2, this will become our new starting color (yellow)		
	j	draw_second_bottom_row		# Now we are ready to move to draw_second_bottom_row
	
draw_second_bottom_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_second_bottom	# If i >= 64, go to done_second_bottom to set and reset registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, second_bottom_colors	# If address in $a2 equals address in $s3 (last color), go to second_bottom_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_bottom_row		# Loop again
second_bottom_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_second_bottom_row		# Loop again
done_second_bottom:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $zero, 0			# Set $a3 (X) to 0 again
	addi	$a1, $a1, -1			# Add to -1 to $a1 (Y) to move up one row
	move	$a2, $s3			# Move address of color in $s3 to $a2, this will become our new starting color (green)		
	j	draw_third_bottom_row		# Now we are ready to move to draw_third_bottom_row

draw_third_bottom_row:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_bottom		# If i >= 64, go to done_bottom as the full border has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a3, $a3, 1			# Add 1 to X to move right one position
	beq	$a2, $s3, third_bottom_colors	# If address in $a2 equals address in $s3 (last color), go to third_bottom_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_bottom_row		# Loop again
third_bottom_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_third_bottom_row		# Loop again
	
done_bottom:
	# Pop $ra off the stack to jump back to draw_bottom_border function call
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
########################################################################
# Function to draw RIGHT BORDER
# Note that we are starting at (63, 0) and moving to the left to create more rows
# X will start with 63
# Y will start with 0
draw_right_border:
	# Push current address in $ra onto the stack, $ra contains address of jal draw_left_border instruction
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$s4, $zero, 0			# Set $s4 = i to 0 again 
	addi	$a3, $zero, 63			# Set $a3 = X coordinate to 63
	addi	$a1, $zero, 0			# Set $a1 = Y coordinate to 0 again
	add	$a2, $zero, $s3			# a2 = address of last color in border_colors array (which is in $s3, green)
draw_first_right_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_first_right	# If i >= 64, go to exit for now
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, first_right_colors	# If address in $a2 equals address in $s3 (last color), go to first_right_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_first_right_col		# Loop again
first_right_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_first_right_col		# Loop again
done_first_right:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $a3, -1			# Subtract 1 from current $a3 (X) to move left one position
	addi	$a1, $zero, 0			# Set $a1 (Y) to 0 again
	move	$a2, $s2			# Move address of starting color $s2 to $a2, this will become our new starting color (yellow)		
	j	draw_second_right_col		# Now we are ready to move to draw_second_right_col

draw_second_right_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_second_right	# If i >= 64, go to done_second_right to reset and set registers
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, second_right_colors	# If address in $a2 equals address in $s3 (last color), go to second_right_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_second_right_col		# Loop again
second_right_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_second_right_col		# Loop again
done_second_right:
	addi	$s4, $zero, 0			# Set i to 0 again before moving to next line
	addi	$a3, $a3, -1			# Subtract 1 from current $a3 (X) to move left one position
	addi	$a1, $zero, 0			# Set $a1 (Y) to 0 again
	move	$a2, $s3			# Move address of color in $s3 to $a2, this will become our new starting color (green)		
	j	draw_third_right_col		# Now we are ready to move to draw_third_right_col

draw_third_right_col:
	add	$s5, $a2, $zero			# $s5 will hold address of color in $a2 temporarily
	bge	$s4, $s1, done_right		# If i >= 64, go to done_right as the full border has been drawn
	la	$a2, black			# Store the address of the color black into $a2
	jal	draw_pixel			# Draw the pixel in black
	move	$a2, $s5			# Move in the address of the intended color from $s5 into $a2
	jal	draw_pixel			# Draw the pixel with the new color now loaded in 
	addi	$a1, $a1, 1			# Add 1 to Y to move down one position
	beq	$a2, $s3, third_right_colors	# If address in $a2 equals address in $s3 (last color), go to third_right_colors for reset
	addi	$a2, $a2, 4			# Otherwise, move to next array element in array of colors
	addi	$s4, $s4, 1			# Add 1 to i to increment loop counter
	j	draw_third_right_col		# Loop again
third_right_colors:
	la	$a2, border_colors		# Load starting address of colors since we have iterated through colors array fully
	addi	$s4, $s4, 1			# Increment i to move to next pixel
	j 	draw_third_right_col		# Loop again

done_right:
	# Pop $ra off the stack to jump back to draw_right_border function call
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
	# Jump back to function call in specific draw branch
	jr $ra
######################################################################
