######### Lawrence Liu ##########
######### 113376858 ##########
######### lawliu ##########

.text
.globl initialize
initialize:
move $t8, $a1

li $v0, 13	#READ FILE
li $a1, 0
li $a2, 0
syscall

move $t9, $v0	#moves file into t9
move $a1, $t8

li $t2, 0 #\n\r counter
li $t3, 6

row_column_loop:
	li $v0, 14	#reads one character
	move $a0, $t9
	li $a2, 1
	syscall
	
	lw $t0, 0($a1)
	li $t1, 10
	beq $t0, $t1, row_column_loop_intermission
	li $t1, 13
	beq $t0, $t1, row_column_loop_intermission
	continue:
	addi $t0, $t0, -48		#gets int value
	sw $t0, 0($a1)			#stores int value into buffer
	addi $a1, $a1, 4
	
	addi $t3, $t3, -1		#decrements counter
	beqz $t3, get_row_and_column		#counter == 0, move onto matrix
	
	j row_column_loop
	
row_column_loop_intermission:
	addi $t3, $t3, -1
	beqz $t3, get_row_and_column
	
	j row_column_loop
	
get_row_and_column:
	move $a1, $t8			#reset buffer cursor
	lw $t3, 0($a1)			#row
	
	addi $t3, $t3, 48		#check if > 1 and < 9
	li $t5, '1'
	blt $t3, $t5, initialize_error
	li $t5, '9'
	bgt $t3, $t5, initialize_error
	addi $t3, $t3, -48
	
	lw $t4, 4($a1)			#column
	addi $t4, $t4, 48
	li $t5, '1'
	blt $t4, $t5, initialize_error
	li $t5, '9'
	bgt $t4, $t5, initialize_error
	addi $t4, $t4, -48
	
	addi $a1, $a1, 8
	
	mul $t5, $t4, $t3		#get counter
	move $t7, $t3
	j matrix_loop
	
matrix_loop:
	li $t6, '0'
	li $v0, 14	#reads one character
	move $a0, $t9
	li $a2, 1
	syscall
	
	lw $t0, 0($a1)
	li $t1, 10
	beq $t0, $t1, count_newline	#counts \n
	li $t1, 13
	beq $t0, $t1, matrix_loop
	
	li $t6, '0'
	blt $t0, $t6, initialize_error
	li $t6, '9'
	bgt $t0, $t6, initialize_error
	
	addi $t0, $t0, -48		#gets int value
	sw $t0, 0($a1)			#stores t0 into buffer.
	addi $a1, $a1, 4		#next byte of buffer

	addi $t5, $t5, -1
	beqz $t5, last_check
	
	j matrix_loop
	
count_newline:
	addi $t2, $t2, 1
	j matrix_loop
	
last_check:
	addi $t2, $t2, 1
	beq $t2, $t7, initialize_buffer
	j initialize_error
	
initialize_buffer:
	move $a0, $t8
	li $v0, 1
	jr $ra
	
initialize_error:
	move $a1, $t8
	li $t7, 85
	
	j reset_buffer
	
reset_buffer:
	li $t0, 0
	sw $t0, 0($a1)
	addi $a1, $a1, 4
	addi $t7, $t7, -1
	beqz $t7, finish_reset_buffer
	j reset_buffer
	
finish_reset_buffer:
	move $a0, $t8
	
	li $v0, -1
	jr $ra
 	
.globl write_file
write_file:
li $t5, 0
li $t6, 0
 move $t0, $a1

 li $t9, '\n'

 li $v0, 13
 li $a1, 1
 li $a2, 0
 syscall
 
 move $t1, $v0 
 move $a1, $t0

 
 li $t2, 0 #counter
 li $t5, 0 #counter
 
 write_row:
 	lb $t3, 0($a1)
 
	lb $t4, 0($a1)
	addi $t4, $t4, 48
	sb $t4, 0($a1)
	
 	sb $t9, 1($a1)		#stores \n
 	
 	#li $v0, 4
 	#move $a0, $a1
 	#syscall
 	
 	li $v0, 15
 	move $a0, $t1		#file descriptor
 	li $a2, 2
 	syscall
 	
 	addi $a1, $a1, 4
 	
 	j write_column
 
 write_column:
 	lb $t8, 0($a1)
 	sb $t9, 1($a1)
 	
 	lw $t4, 0($a1)
	addi $t4, $t4, 48
	sb $t4, 0($a1)
 	
 	#li $v0, 4
 	#move $a0, $a1
 	#syscall
 	
 	li $v0, 15
 	move $a0, $t1
 	li $a2, 2
 	syscall
 	
 	addi $a1, $a1, 4
 	
 	j add_48_buffer
 	
 add_48_buffer:
 	mul $t6, $t3, $t8	#t6 = row * column = holds max count
 	move $t7, $t6
 	lb $t4, 0($a1)
 	addi $t4, $t4, 48
 	sb $t4, 0($a1)
 	addi $a1, $a1, 4
 	addi $t2, $t2, 1
 	beq $t2, $t6, write_matrix_first
 	j add_48_buffer
 	
 write_matrix_first: 
 	addi $t8, $t8, -1
 	addi $t3, $t3, -1
 	li $t2, 0 #counter
 	
 	li $t4, 4
 	mul $t6, $t6, $t4
 	sub $a1, $a1, $t6
 	
 	j write_matrix
 
 write_matrix: #writing column from number 1 to second last number.
 	
 	# Writes character/byte to file
 	li $v0, 15
 	move $a0, $t1
 	li $a2, 1
 	syscall
 	
 	# Prints each character out
 	#li $v0, 4
 	#move $a0, $a1
 	#syscall
 	
 	addi $a1, $a1, 4 # Iterates through word array
 	
 	addi $t2, $t2, 1 # Column Counter
 	beq $t2, $t8, write_matrix_2 # Checks if iterated through all columns. 
 	j write_matrix
 	
 write_matrix_2: #writing last number with new line
 	beq $t5, $t3, write_matrix_3 # Checks if all but last character is printed
 	sb $t9, 1($a1) # Stores new line into byte
 	
 	li $v0, 15
 	move $a0, $t1
 	li $a2, 2
 	syscall
 	
 	#li $v0, 4
 	#move $a0, $a1
 	#syscall
 	
 	addi $t5, $t5, 1	#increments row counter
 	
 	addi $a1, $a1, 4	#Iterates to next byte
 	li $t2, 0 #counter
 	
 	j write_matrix
 
 write_matrix_3: #Prints last character
 	#sb $t9, 1($a1)
 	li $v0, 15
 	move $a0, $t1
 	li $a2, 1
 	syscall
 	
 	j done_write_file
 
 done_write_file:
 	li $v0, 16
 	move $a0, $t1
 	syscall
 	
 	jr $ra
 	
 
.globl rotate_clkws_90
rotate_clkws_90:
  li $t2, 0
  li $t4, 0
  li $t5, 0 #counter
  
  move $t1, $a0		#HOLDS FILE BUFFER
  move $t2, $a1		#HOLDS FILE DESCRIPTOR

  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $a0, $t1
  move $a1, $t2
  
  j get_90_column
  
  get_90_column:
  	#addi $sp, $sp, -4
  	lw $t0, 4($a0)
  	#sw $t0, 0($sp)
  	j get_90_row
  
  get_90_row:
  	#addi $sp, $sp, -4
  	lw $t1, 0($a0)
  	#sw $t0, 4($a1)
  	#sw $t1, 0($sp)
  	addi $a0, $a0, 8
  	
  	li $t3, 4
  	li $t5, 0
  	li $t8, 0
  	j size_matrix_rotate
  	
  size_matrix_rotate:
  	mul $t2, $t1, $t0
  	move $t8, $t0
  	mul $t4, $t3, $t2
  	
  	#sub $sp, $sp, $t4
  	
  	addi $sp, $sp, -4
  	
  	#mul $t4, $t3, $t1
  	mul $t4, $t0, $t3
  	addi $t4, $t4, -4
  	add $a0, $a0, $t4
  	
  	addi $t1, $t1, -1
  	
  	mul $t4, $t3, $t0
  	mul $t6, $t4, $t1          #row - 1 * column * 4
  	
  	j rotate_matrix
  	
  	#mul $t4, $t3, $t0
  	#mul $t6, $t4, $t1          #row - 1 * column * 4
  	#add $a1, $a1, $t4
  	#j rotate_matrix
 
  rotate_matrix:
  	beqz $t8, done_rotate_intermission
  	beq $t5, $t1, rotate_first_value
  	lw $t9, 0($a0)
  	add $a0, $a0, $t4
  	sw $t9, 0($sp)
  	addi $sp, $sp, -4
  	
  	addi $t5, $t5, 1
  	j rotate_matrix
  	
  rotate_first_value:
  	lw $t9, 0($a0)
  	sw $t9, 0($sp)
  	
  	addi $t8, $t8, -1
  	beqz $t8, done_rotate_intermission
  	
  	addi $sp, $sp, -4
  	
  	sub $a0, $a0, $t6
 	addi $a0, $a0, -4
 	#add $a1, $a1, $t4
  	li $t5, 0
  	
  	j rotate_matrix
  	
  done_rotate_intermission:
  	#mul $t4, $t3, $t2
  	sub $a0, $a0, $t6
  	j rotate_90_row
  	
  rotate_90_column:
  	lw $t0, 4($a0)
  	addi $sp, $sp, -4
  	sw $t0, 0($sp)
  	
  	j done_rotate_intermission_2
  	
  rotate_90_row:
  	addi $a0, $a0, -8
  	lw $t0, 0($a0)
  	addi $sp, $sp, -4
  	sw $t0, 0($sp)
  	
  	j rotate_90_column
  	
  done_rotate_intermission_2:
  	addi $t2, $t2, 2
  	move $t0, $t2
  	j done_rotate	
  
  done_rotate:
  	beqz $t2, done_rotate_2
  	lw $t7, 0($sp)
  	addi $sp, $sp, 4
  	sw $t7, 0($a0)
  	addi $a0, $a0, 4
  	addi $t2, $t2, -1
  	
  	j done_rotate
  	
  done_rotate_2:  
  	li $t1, 4
  	mul $t0, $t0, $t1
  	sub $a0, $a0, $t0
  
  	move $t9, $a1
  	move $a1, $a0
  	move $a0, $t9
		
  	jal write_file
  	
  	lw $ra, 0($sp)
  	addi $sp, $sp, 4
 
 	jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
  li $t0, 85
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)
  
  jal rotate_clkws_90
  
  lw $a1, 0($sp)
  lw $a0, 4($sp)
  
  j rotate_180_intermission
  
rotate_clkws_180_2:
  lw $a1, 0($sp)
  lw $a0, 4($sp)
 
  jal rotate_clkws_90
  
  lw $a1, 0($sp)
  lw $a2, 4($sp)
  lw $ra, 8($sp)
  
  addi $sp, $sp, 12
  
  jr $ra

rotate_180_intermission:
  li $t3, 2608
  li $t4, 4
  lw $t1, 0($a0)
  
  sub $t1, $t1, $t3
  sw $t1, 0($a0)
  
  lw $t2, 4($a0)
  sub $t2, $t2, $t3
  sw $t2, 4($a0)
  
  addi $a0, $a0, 8
  
  mul $t2, $t2, $t1
  mul $t4, $t2, $t4
  
  rotate_180_intermission_loop:
  	lw $t1, 0($a0)
  	bge $t1, $t3, rotate_180_intermission_loop_2608
  	
  	addi $t1, $t1, -48
  	sw $t1, 0($a0)
  	
  	addi $a0, $a0, 4
  	
  	addi $t2, $t2, -1
  	bnez $t2, rotate_180_intermission_loop
  	
  	j rotate_180_intermission_2
  	
  rotate_180_intermission_loop_2608:
  	sub $t1, $t1, $t3
  	sw $t1, 0($a0)
  	addi $a0, $a0, 4
  	addi $t2, $t2, -1
  	
  	j rotate_180_intermission_loop
  
   rotate_180_intermission_2:
   	sub $a0, $a0, $t4
   	addi $a0, $a0, -8
   	
   	j rotate_clkws_180_2

.globl rotate_clkws_270
rotate_clkws_270:
  li $t0, 85
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)
  
  jal rotate_clkws_90
  
  lw $a1, 0($sp)
  lw $a0, 4($sp)
  
  j rotate_270_intermission
  
rotate_clkws_270_2:
  lw $a1, 0($sp)
  lw $a0, 4($sp)
 
  jal rotate_clkws_180
  
  lw $a1, 0($sp)
  lw $a2, 4($sp)
  lw $ra, 8($sp)
  
  addi $sp, $sp, 12
  
  jr $ra

rotate_270_intermission:
  li $t3, 2608
  li $t4, 4
  lw $t1, 0($a0)
  
  sub $t1, $t1, $t3
  sw $t1, 0($a0)
  
  lw $t2, 4($a0)
  sub $t2, $t2, $t3
  sw $t2, 4($a0)
  
  addi $a0, $a0, 8
  
  mul $t2, $t2, $t1
  mul $t4, $t2, $t4
  
  rotate_270_intermission_loop:
  	lw $t1, 0($a0)
  	bge $t1, $t3, rotate_270_intermission_loop_2608
  	
  	addi $t1, $t1, -48
  	sw $t1, 0($a0)
  	
  	addi $a0, $a0, 4
  	
  	addi $t2, $t2, -1
  	bnez $t2, rotate_270_intermission_loop
  	
  	j rotate_270_intermission_2
  	
  rotate_270_intermission_loop_2608:
  	sub $t1, $t1, $t3
  	sw $t1, 0($a0)
  	addi $a0, $a0, 4
  	addi $t2, $t2, -1
  	
  	j rotate_270_intermission_loop
  
   rotate_270_intermission_2:
   	sub $a0, $a0, $t4
   	addi $a0, $a0, -8
   	
   	j rotate_clkws_270_2

.globl mirror
mirror:
  addi $sp, $sp, -12
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $a1, 0($sp)
  
  lw $t0, 0($a0) #holds row
  lw $t1, 4($a0) #holds column
  
  addi $a0, $a0, 8
  
  mul $t9, $t0, $t1 #size of the matrix
  
  addi $t5, $t0, -1
  li $t2, 4
  mul $t7, $t1, $t2
  
  li $t8, 0 #counter
  li $t3, 0
  
  mirror_go_to_last:
  	add $a0, $a0, $t7
  	addi $t8, $t8, 1
  	beq $t8, $t5, mirror_go_to_last_intermission
  	
  	j mirror_go_to_last
  	
  mirror_go_to_last_intermission:
  	li $t8, 0
  	j mirror_loop
  
  mirror_loop:
  	addi $sp, $sp, -4
  	lw $t2, 0($a0)
  	sw $t2, 0($sp)
  	
  	addi $a0, $a0, 4
  	
  	addi $t8, $t8, 1
  	beq $t8, $t1, mirror_loop_2
  	
  	j mirror_loop
  	
  mirror_loop_2:
  	beq $t3, $t5, mirror_done
  	sub $a0, $a0, $t7
  	sub $a0, $a0, $t7
  	addi $t3, $t3, 1
  	
  	li $t8, 0
  	
  	j mirror_loop
  
  mirror_done:
  	sub $a0, $a0, $t7
	addi $a0, $a0, -8
  	
  	addi $sp, $sp, -8
  	sw $t1, 4($sp)
  	sw $t0, 0($sp)
  	
  	li $t7, 4
  	mul $t7, $t7, $t9
  	
  	addi $t9, $t9, 2
  	li $t8, 0
  	
  	j mirror_done_2
  	
  mirror_done_2:
  	beq $t8, $t9, write_mirror
  	
  	lw $t0, 0($sp)
  	sw $t0, 0($a0)
  	addi $a0, $a0, 4
  	addi $sp, $sp, 4
  	
  	addi $t8, $t8, 1
  	
  	j mirror_done_2
  	
  write_mirror:
  	lw $a0, 4($sp)
  	lw $a1, 0($sp)
  	
  	move $t9, $a0
  	move $a0, $a1
  	move $a1, $t9
  	
  	jal write_file
  	
  	lw $a1, 0($sp)
  	lw $a0, 4($sp)
  	lw $ra, 8($sp)

  	addi $sp, $sp, 12
  	
  	addi $sp, $sp, -340
  	addi $sp, $sp, 340
  	
 	jr $ra

.globl duplicate
duplicate:
 li $v1, 1
 
 li $t6, 0

 addi $sp, $sp -12
 sw $s1, 0($sp)
 sw $s2, 4($sp)
 sw $s3, 8($sp)
 
 move $s1, $a0

 lw $t0, 0($a0) #HOLDS ROW
 lw $t1, 4($a0) #HOLDS COLUMN
 
 move $t9, $t0	#row
 move $s2, $t1

 addi $a0, $a0, 8
 
 li $t2, 4
 mul $t2, $t2, $t1
 
 add $a0, $a0, $t2
 move $s1, $a0		#always start at second row
 
 move $t5, $t2
 
 addi $s2, $s2, -1
 
 duplicate_check_character: #checks the character
 	lw $t3, 0($a0)
 	sub $a0, $a0, $t2
 	lw $t4, 0($a0)
 	
 	j duplicate_check_character_2
 
 duplicate_check_character_2:	#compares the character to the previous row. keep checking row to previous rows.
 	addi $a0, $a0, 4
 	add $a0, $a0, $t2
 	
 	addi $s2, $s2, -1
 	
 	beq $t3, $t4, duplicate_check_character
 	bne $t4, $t3, duplicate_check_character_intermission	#if not equal, move onto next row
 	
 	j duplicate_check_character_intermission
 
 duplicate_check_character_intermission:
 	bltz $s2, duplicate_success
 	move $a0, $s1
 	move $s2, $t0
 	move $t8, $t5
 	j duplicate_next_row
 	
 duplicate_next_row:
 	sub $t2, $t2, $t5	#next row
 	beq $t2, $zero, duplicate_1
 	j duplicate_check_character
 	
 duplicate_1:	#only has one function, to tell whether or not it is duplicate
 	 addi $t9, $t9, -1
 	 beq $t9, $zero duplicate_fail
 	 j continue_duplicate_check
 	 
 continue_duplicate_check:
 	 addi $v1, $v1, 1
 	 mul $t8, $v1, $t8
 	 add $a0, $a0, $t5
	 add $s1, $s1, $t5 	 
 	 move $t2, $t8
 	 
 	 j duplicate_check_character
 	 
 duplicate_fail:
 	lw $s0, 0($sp)
 	lw $s1, 4($sp)
 	lw $s2, 8($sp)		
 
 	addi $sp, $sp, 12	#restore stack
 	
 	li $v0, -1
 	li $v1, 0
 	jr $ra
 	
 duplicate_success:
 	lw $s1, 0($sp)
 	lw $s2, 4($sp)
 	lw $s3, 8($sp)		
 
 	addi $sp, $sp, 12	#restore stack
 	
 	li $v0, 1
 	addi $v1, $v1, 1
 	jr $ra
