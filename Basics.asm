################# Brice Joseph #################
################# bbjoseph #################
################# 114588946 #################
################# DON'T FORGET TO ADD GITHUB USERNAME IN BRIGHTSPACE #################

################# DO NOT CHANGE THE DATA SECTION #################

.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "Invalid Arguments\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
invalid_hand_msg: .asciiz "Loot Hand Invalid\n"
newline: .asciiz "\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""

.text
.globl hw_main
hw_main:
    sw $a0, num_args #stores number args
    sw $a1, arg1_addr #stores arg1 adress
    addi $t0, $a1, 2 #adds 2 
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	
	lw $t2, num_args #loads the number of arguments (2)
	li $t1, 2 #loads a temp value of 2 to $t1
	bne $t2, $t1, args_err #compares 2 to the value of num_args, if NOT equal, jumps to error msg
	
	#need to check the first argument's 2nd char is null
	
	lw $t1, arg1_addr #loads the arg in t1
	lb $t3, 1($t1) #now we check if the second char is equal to null 
	bne $t3, $zero, invalid_args #compare the second character with the null
	
	 
	 #need to check he first argument must be either "D", "O", "S", "T", "E", "H", "U", "F", or "L". 
	 #Otherwise, print error message in label invalid_arg_msg and terminate. 
	 
	 lb $t4, 0($t1) #loads the char stored in #t1 (first argument)
	 
	 
	 #SWITCH STATMENT
	 
	 li $t1, 'D' #loads char D into register
	 beq $t4, $t1, str_to_dec #compares if t1 == d, then jump to appropriate label
	 
	 li $t1, 'O'
	 beq $t4, $t1, decode
	 
	 li $t1, 'S'
	 beq $t4, $t1, decode
	 
	 li $t1, 'T'
	 beq $t4, $t1, decode
	 
	 li $t1, 'E'
	 beq $t4, $t1, decode
	 
	 li $t1, 'H'
	 beq $t4, $t1, decode
	 
	 li $t1, 'U'
	 beq $t4, $t1, decode
	 
	 li $t1, 'F'
	 beq $t4, $t1, hex_to_float
	 
	 li $t1, 'L'
	 beq $t4, $t1, pirate
	 
	 #Otherwise jump to invalid error
	 
	 j invalid_args
	 
#PART 2:

str_to_dec:
	
	lw $t3, arg2_addr #loads the address from memory
	#now loop through the string and find the length

	lbu $t2, 0($t3)
	li $t1, '0'
	blt $t2, $t1, invalid_args
	
	li $t1, 0 #instantiate counter
for_length:
	
	lbu $t2, 0($t3) #loads byte of first char 
	beqz $t2, continue #checks if its equal to null character, which means length was found
	addi $t1, $t1, 1 #increments the counter
	addi $t3, $t3, 1 #moves to next char bytw
	j for_length #jumps back to loop
	
	

continue: #reaches here once length is found $t1 <-----------

	beqz $t1, invalid_args #length is less than 1 so invalid
	li $t4, 32 #loads 32
	bgt $t1, $t4, invalid_args #length is greater than 32 so invalid
	addi $t3, $t3, -1
	
	#now need a loop to convert to decimal
	#loop should also check if char is not a 0 or 1
	#lw $t3, arg2_addr
	li $t4, '1'
	li $t7, 0
	li $t6, 0


	
increment_loop:
	
	lbu $t2, 0($t3) #load byte
	addi $t2, $t2, -48
	beq $t7, $t1, finish_p2 
	#bne $t4, $t2, continue_increment #if character is not 1, then continue, dont do anything
	sllv $t5, $t2, $t7 #need to shift left
	add $t6, $t6, $t5
	addi $t7, $t7, 1
	addi  $t3, $t3, -1
	
	j increment_loop
	
	
continue_increment:

	addi $t1,$t1, -1
	addi $t6, $t6, -1
	addi $t3, $t3, 1
	
	j increment_loop

	
	
finish_p2:

	li $v0, 1
	move $a0, $t6
	syscall
	j done

	

decode:
	

	li $t3, '0' #loads 0
	lw $s1, arg2_addr #loads the address of second arg
	lbu $t4, 0($s1) #loads the first char
	bne $t4, $t3, invalid_args #compares first char to 0
	li $t3, 'x'
	lbu $t4, 1($s1) #loads the second char
	bne $t4, $t3, invalid_args #compares second char to x
	addi $s1, $s1, 2 #doesnt count the first two if valid string so we can start length counter
	
	li $t5, 0 #length counter
	li $s4, 0 
	
decode_length:
	
	lbu $t4, 0($s1) #loads the first char
	beqz $t4, validate_length #if NULL char found then jump to validate length
	addi $t5, $t5, 1
	addi $s1, $s1, 1
	
	j decode_length
	
	
validate_length: #note $t5 is the length
	
	li $t3, 8 #Loads 8
	bgt $t5, $t3, invalid_args #If length is greater than 8, branch
	li $t3, 1 #loads 1
	blt $t5, $t3, invalid_args #if lenght is less than 1 , branch
	
	lw $s1, arg2_addr
	addi $s1, $s1, 2
	j hex_valid
	
hex_valid:
	
	lbu $t4, 0($s1)
	beqz $t4, hex_loop_start #***** ending 
	li $t3, '0' #loads 0
	blt $t4, $t3, invalid_args #if not a number or character, it quits
	li $t3, '9' #loads 9 
	bgt $t4, $t3, hex_valid2 #if greater than 9, the need to check if its a letter
	addi $s1, $s1, 1
	
	j hex_valid

hex_valid2:

	li $t3, 'A'
	blt $t4, $t3, invalid_args #less than A means its not a letter or a number
	li $t3, 'F'
	bgt $t4, $t3, hex_valid3 # greater than F, so check again
	addi $s1, $s1, 1
	
	j hex_valid

hex_valid3:

	li $t3, 'a' 
	blt $t4, $t3, invalid_args #if between F and a, then quit
	li $t3, 'f'
	bgt $t4, $t3, invalid_args #if greater than f, quit since it doesn't meet hex requirements
	addi $s1, $s1, 1
	
	j hex_valid
	
hex_loop_start:
	
	lw $s1 arg2_addr
	addi $s1, $s1, 2
	j hex_loop

hex_loop:

	lbu $t4, 0($s1)
	beqz $t4, hex_finish
	li $t3, '9'
	ble $t4, $t3, hex_solve1
	li $t3, 'F'
	ble $t4, $t3, hex_solve2
	li $t3, 'f'
	ble $t4, $t3, hex_solve3
	
hex_solve1:

#procedure according to TA:
#1. convert the character into a int value by subtracting ascii value
#2. Shift a destination register by 4 since its hex
#3. Find way to convert to decimal and add to dest register (probably using or or and)
	
	li $t3, 4
	addi, $t5, $t4, -48 #convert each char into a int
	sllv $s4, $s4, $t3 #SHIFT LEFT TO MULTIPLY 16
	or $s4, $s4, $t5 #OR THE TOTAL BY THE INTEGER TO MAINTAIN AND MAKE APPROPRIATE SHIFT
	
	addi $s1, $s1, 1
	
	j hex_loop

hex_solve2:
	
	li $t3, 4
	addi, $t5, $t4, -55 
	sllv $s4, $s4, $t3
	or $s4, $s4, $t5
	
	addi $s1, $s1, 1
		
	j hex_loop

	

hex_solve3:
	
	li $t3, 4
	addi, $t5, $t4, -87
	sllv $s4, $s4, $t3
	or $s4, $s4, $t5
	
	addi $s1, $s1, 1
	
	j hex_loop
	

hex_finish:
#Switch cases

	lw $t1, arg1_addr
	lb $t6, 0($t1)
	li $t3, 'O'
	beq $t3, $t6, op
	li $t3, 'S'
	beq $t3, $t6, rs
	li $t3, 'T'
	beq $t3, $t6, rt
	li $t3, 'E'
	beq $t3, $t6, rd
	li $t3, 'H'
	beq $t3, $t6, shamt	
	li $t3, 'U'
	beq $t3, $t6, funct

#EXTRACT BITS BY CALCULATING THE SHIFT AND USING SLL AND SRL
op:

	srl $s4, $s4, 26
	j hex_out
	
rs:
	sll $s4, $s4, 6
	srl, $s4, $s4, 27
	j hex_out
	
rt:
	
	sll $s4, $s4, 11
	srl $s4, $s4, 27
	j hex_out

rd:
	
	sll $s4, $s4, 16
	srl $s4, $s4, 27	
	j hex_out
	
shamt:
	
	sll $s4, $s4, 21
	sra $s4, $s4, 27 #USE SRA TO MAINTAIN THE SIGN BIT
	
	j hex_out
	
funct:
	sll $s4, $s4, 26
	srl $s4, $s4, 26
	
	j hex_out


hex_out:

	li $v0, 1
	move $a0, $s4
	syscall
	j done
	


hex_to_float:

	lw $t3, arg2_addr
	li $t5, 0 #length counter
	
	hex_length:
	
	lbu $t4, 0($t3)
	beqz $t4, check_length
	addi $t5, $t5, 1 #increment length
	addi $t3, $t3, 1 # move byte over
	
	j hex_length
	
	
	check_length:
	
	li $t6, 8 #valid length
	bne $t6, $t5, invalid_args #if 8 != 8 throw error, otherwise jump to hex validation
	lw $t3, arg2_addr
	add $t2, $t5, $0 #length
	j hex_float_valid 
	
hex_float_valid:
#SAME VALIDATION EXCEPT LENGTH IS 8

	lbu $t4, 0($t3)
	beqz $t4, hex_to_float_loop_start
	li $t5, '0'
	blt $t4, $t5, invalid_args
	li $t5, '9'
	bgt $t4, $t5, hex_to_float_valid2
	addi $t3, $t3, 1
	
	j hex_float_valid

hex_to_float_valid2:
	
	li $t5, 'A'
	blt $t4, $t5, invalid_args
	li $t5, 'F'
	bgt $t4, $t5, hex_to_float_valid3
	addi $t3, $t3, 1
	
	j hex_float_valid
	
hex_to_float_valid3:

	li $t5, 'a'
	blt $t4, $t5, invalid_args
	li $t5, 'f'
	bgt $t4, $t5, invalid_args
	addi $t3 $t3, 1
	
	j hex_float_valid
		
	
	
	
hex_to_float_loop_start:
	
	lw $t3, arg2_addr
	li $t5, -1 #counter
	li $s0, 0 #empty register
	
	j hex_float_start

hex_float_start:

	lbu $t4, 0($t3)
	beqz $t4, special_case
	li $t8, '9'
	ble $t4, $t8, float_1
	li $t8, 'F'
	ble $t4, $t8, float_2
	li $t8, 'f'
	ble $t4, $t8, float_3
	
	
float_1:
#same calculation at Part 3
	li $t8, 4
	addi $t4, $t4, -48
	sllv $s0, $s0, $t8
	or $s0, $s0, $t4
	
	j continue_hex_float
	
	

float_2:
	
	li $t8, 4
	addi $t4, $t4, -55
	sllv $s0, $s0, $t8
	or $s0, $s0, $t4
	
	j continue_hex_float
	
	
float_3:
	
	li $t8, 4
	addi $t4, $t4, -87
	sllv $s0, $s0, $t8
	or $s0, $s0, $t4
	
	j continue_hex_float
	


continue_hex_float:
	
	addi $t3, $t3, 1
	addi $t5, $t5, 1
	
	j hex_float_start

special_case:
	
	#hex values can be loaded into registers using 0x
	
	li $t5, 0x00000000
	beq $t5, $s0, zero_error
	li $t5, 0x80000000
	beq $t5, $s0, zero_error
	li $t5, 0xFF800000
	beq $t5, $s0, inf_error1
	li $t5, 0x7F800000
	beq $t5, $s0, inf_error2
	li $t5, 0x7f800001
	bge $s0, $t5, check_NaN2 #greater than the initial so make another check to make sure its in range
	li $t5, 0xFFFFFFFF
	ble $s0, $t5, check_NaN1 #make another check is see if its lower (negative)
	
	j part4b
	
part4b:

	li $t5, 0
	add $t5, $t5, $s0 #first for the sign bit
	li $s5, 0
	add $s5, $s5, $s0 #next for the exponent
	li $t8, 0
	add $t8, $t8, $s0 #last for the mantissa
	
	sll $s5, $s5, 1 #get rid of sign bit
	srl $s5, $s5, 24 #get rid of mantissa
	addi $s5, $s5, -127 #exponent bias
	
	move $a0, $s5 #sets a0 as the exponent bits
	
	sll $t8, $t8, 9 #mantissa
	srl $t8, $t8, 9
		
	srl $t5, $t5, 31 #gets the sign bit
	li $t3, 1
	beq $t5, $t3, negative
	
	li $t3, '1' #set up for a positive value
	la $t7, mantissa
	sb $t3, 0($t7)
	li $t3, '.'
	sb $t3, 1($t7)
	
	addi $t7, $t7, 2
	li $t6, 0
	li $t9, 22
	
	j build_string
	
negative: #basically a set up for a negative value
	li $t3, '-'
	la $t7, mantissa
	sb $t3, 0($t7) #appends a negative sign to the front!
	
	li $t3, '1'
	sb $t3, 1($t7) #appends a one sign 
	
	li $t3, '.'
	sb $t3, 2($t7) #appends a period
	
	addi $t7, $t7, 3
	li $t6, 0 #counter
	li $t9, 23
	
	j build_string_neg
	
build_string:
	#creates empty string of O's after 1.
	beq $t6, $t9, math
	li $t3, '0'
	sb $t3, 0($t7)
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	
	
	j build_string
	
	
build_string_neg:
	
	beq $t6, $t9, math_neg
	li $t3, '0'
	sb $t3, 0($t7)
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	
	j build_string_neg


math:
	
	li $t3, 0
	addi $t7, $t7, 1
	sb $t3, 0($t7) #add the NULL character to the string at the end 
	
	li $t3, 23 #for the high counter
	li $t6, 0 #used for the counter to subtract from 23 and get position
	
	j string_loop
	
math_neg:

	li $t3, 0
	addi $t7, $t7, 1
	sb $t3, 0($t7) #add the NULL character to the string at the end
	li $t3, 23 #for the high counter
	li $t6, 0 #used for the counter to subtract from 23 and get position
	
	j string_loop_neg
	
string_loop:
	
	li $t4, 2
	beqz $t8, mantissa_finish #ending condition
	div $t8, $t4 #div mantissa decimal value by 2
	mflo $t8 #LO IS THE QUOTIENT
	mfhi $t5 #THIS IS THE REMAINDER
	subu $t2, $t3, $t6 #SUBTRACTS THE COUNTER FROM 23 TO GET THE POSITION WE WANT
	
	addi $t6, $t6, 1 #INCREMENT COUNTER
	
	la $t7, mantissa
	addi $t7, $t7, 1
	
	j find_position

string_loop_neg:
	li $t4, 2
	beqz $t8, mantissa_finish #ending condition
	div $t8, $t4 #div mantissa decimal value by 2
	mflo $t8 #LO IS THE QUOTIENT
	mfhi $t5 #THIS IS THE REMAINDER
	subu $t2, $t3, $t6 #SUBTRACTS THE COUNTER FROM 23 TO GET THE POSITION WE WANT
	
	addi $t6, $t6, 1 #INCREMENT COUNTER
	
	la $t7, mantissa
	addi $t7, $t7, 2
	
	j find_position_neg


find_position:

	
	add $t7, $t7, $t2 #adds the counter and sets the position
	
	li $s6, 0
	li $s7, 1
	beq $s6, $t5, append_zero # means remainder is 1, but branch since its zero
	
	li $s7, '1'
	sb $s7, 0($t7) #appends a one
	
	
	j string_loop
	
find_position_neg:


	add $t7, $t7, $t2 #adds the counter and sets the position
	
	li $s6, 0
	li $s7, 1
	beq $s6, $t5, append_zero_neg # means remainder is 1, but branch since its zero
	
	li $s7, '1'
	sb $s7, 0($t7) #appends a one
	
	#la $t7, mantissa
	#li $v0, 4
	#move $a0, $t7
	#syscall
	
	j string_loop_neg
	
append_zero_neg:

	li $s6, '0'
	sb $s6, 0($t7)
	
	
	j string_loop_neg

append_zero:
	
	li $s6, '0'
	sb $s6, 0($t7)
	
	
	j string_loop
	
mantissa_finish:
	
	la $t7, mantissa
	move $a1, $t7

	
	j done
	
check_NaN1:

	li $t5, 0xff800001
	bge $s0, $t5, NaN_error
	
	j part4b
	
check_NaN2:

	li $t5, 0x7FFFFFFF
	ble $s0, $t5, NaN_error
	
	j part4b
#PART 5

pirate:

	lw $t1, arg2_addr
	li $t2, 0 #AMOUNT OF MERCHANTS
	li $t5, 0 #AMOUNT OF PIRATES
	li $t4, '9'
	lbu $t3, 0($t1)
	blt $t3, $t4, invalid_hand
	
	j pirate_loop

pirate_loop:

	lbu $t3, 0($t1) #loads byte
	beqz $t3, pirate_start #if char is NULL, start
	li $t4, 'M' #load M
	beq $t4, $t3, check_M #if the char is equal to M, check next char 
	li $t4, 'P' #load P
	beq $t4, $t3, check_P #if the char is equal to P, check next char
	

check_M:
	
	addi $t1, $t1, 1 #moves one char up
	lbu $t3, 0($t1) #loads that new char
	li $t4, '8'
	bgt $t3, $t4, invalid_hand #greater than 8
	li $t4, '3'
	blt $t3, $t4, invalid_hand #less than 3
	addi $t2, $t2, 1 #ADD TO NUMBER OF MERCHANTS
	addi $t1, $t1, 1 #moves to next char

	j pirate_loop
check_P:

	addi $t1, $t1, 1 #moves one char up
	lbu $t3, 0($t1) #loads that new char
	li $t4, '4'
	bgt $t3, $t4, invalid_hand #greater than 4
	li $t4, '1'
	blt $t3, $t4, invalid_hand #less than 1
	addi $t5, $t5, 1 #ADD TO NUMBER OF PIRATES
	addi $t1, $t1, 1 #moves to next char
	
	j pirate_loop

pirate_start:

	add $t6, $t5, $t2 
	li $t4, 6
	bgt $t6, $t4, invalid_hand
	li $t4, 2
	li $t9, 3
	li $t6, 5
	
	j pirate_loop2

pirate_loop2:

	beq $t6, $t9, pirate_last
	div $t2, $t4 #divide by 2
	mflo $t2 #quotient is in LO
	mfhi $t8 #remainder is in HI
	sllv $t1, $t8, $t9 #shift left logical STARTING at 3
	add $t5, $t5, $t1 #ADD the shifted value to the pirate value
	addi $t9, $t9, 1 #adds the shift increment
	
	j pirate_loop2
	
pirate_last:

	div $t2, $t4 #divide by 2
	mflo $t2 #quotient is in LO
	mfhi $t8 #remainder is in HI
	sllv $t1, $t8, $t9 #shift left logical STARTING at 3
	li $t4 , 0
	sub $t3, $t4, $t1
	add $t5, $t5, $t3
	
	
	li $v0, 1
	move $a0, $t5
	syscall
	j done
	

	
	

	
invalid_hand:
	li $v0, 4
	la $a0, invalid_hand_msg
	syscall
	j done
	

zero_error:

	li $v0, 4
	la $a0, zero
	syscall
	j done
	
inf_error1:

	li $v0, 4
	la $a0, inf_neg
	syscall
	j done
	
inf_error2:

	li $v0, 4
	la $a0, inf_pos
	syscall
	j done
	
NaN_error:
	
	li $v0, 4
	la $a0, nan
	syscall
	j done
	
	


		
args_err:

	li $v0, 4
	la $a0, args_err_msg
	syscall
	j done
	
	
invalid_args:

	li $v0, 4
	la $a0, invalid_arg_msg
	syscall
	j done
	
	
done:
	
	li $v0, 10
	syscall
	


   

