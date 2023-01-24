########### Brice Joseph ############
########### bbjoseph ################
########### 114588946 ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl hash
hash:


	move $t1, $0 #record keeper
  	j hash_loop
  
  
hash_loop:
	
	lb $t0, 0($a0) #loads the first byte
	beqz $t0, hash_finish #if byte equals 0, then branch (end of string)
	add $t1, $t1, $t0 #add the ascii value to record keeper
	addi $a0, $a0, 1 #counter to keep loop going
	j hash_loop #jump back to the function
	
	
	
hash_finish:
	move $v0, $t1 #adds result to the return register
	jr $ra #goes back to caller

.globl isPrime
isPrime:

	addi $t0, $0, 2 #adds 2 to $t0
	blt $a0, $t0, no_prime #if less than 2, then say its not prime
	j prime_loop
	
prime_loop:
	
	beq $t0, $a0, yes_prime #if the counter gets to n-1, its prime
	div $a0, $t0 # divide num/counter
	mfhi $t1 #store remainder in $t1
	beqz $t1, no_prime #if it equal to 0, then its not prime
	addi $t0, $t0, 1 #else add 1 to the counter
	j prime_loop #jump back to the loop

no_prime:
	
	move $v0, $t1 #stores 0 since its not prime
	jr $ra #jumps back
	
yes_prime:
	
	move $v0, $t1 #stores 1 since its not prime
	jr $ra #jumps back

.globl lcm
lcm:

	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	jal gcd #calls gcd 
	move $t0, $v0 #stores the result
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12

	mul $t2, $a1, $a0 #multiplies for division

	div $t2, $t0
	mflo $v0
	
	j finish_lcm
	
finish_lcm:

	
	jr $ra

.globl gcd
gcd: 

	#gcd(a0,a1)
	
	
	beq $a0, $0, return_b #if a==0
	#else
	div $a1, $a0
	mfhi $t7 #remainder is in t7
	move $a1, $a0 # gcd( x, a)
	move $a0, $t7 # gcd (b % a, a)
	
	j gcd
	

return_b:

	move $v0, $a1
	jr $ra

.globl pubkExp
pubkExp:

	move $a1, $a0 #moves into upper bound register
	move $t3, $a0
	addi $a1, $a1, -2
	
	j generate #jumps to generate register
	
generate:

	move $a1, $t3
	li $v0, 42 
	syscall #syscall to RNG
	addi $a0, $a0, 2
	move $t2, $a0 #rng number
	

	j check_gcd #after getting the number, check if the gcd is 1

check_gcd:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	jal gcd #calls the gcd function
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	li $t6, 1 #loads 1 
	bne $t6, $v0, try_again #branch if NOT equal (1 != gcd(x,y))
	move $v0, $t2
	
	jr $ra #return
try_again:

	j generate #jump back to generate to generate a new number

.globl prikExp
prikExp:
	#CHECK IF ARGUMENT IS CO PRIME
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	
	jal gcd #calls the gcd function
	li $t6, 1 #loads 1 
	bne $t6, $v0, not_coprime #branch if NOT equal (1 != gcd(x,y))
	
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	
	addi $sp, $sp, 12
	
	j continue_prik

not_coprime:
	li $t6, -1
	move $v0, $t6 #returns -1 if not co prime
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
  	jr $ra
  	
continue_prik:
	addi $sp,$sp,-32
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	
	move $t8, $a1
	move $t9, $a0
	
	#STORAGE VARIABLES
	li $t1, 0 #pi-2
	li $t2, 1 #pi-1
	li $t0, 1 #p
	li $t3, 0 #qi-2
	li $t4, 0 #qi-1
	

	j prik_loop
	
prik_loop:
	
	beqz $a0, finish_prik
	div $a1, $a0 #Y DIVIDED BY X (y mod x)
	             #At this point we have the remainder and the quotient which is good
	move $t6, $a0 
	mfhi $a0 #remainder is in a0
	mflo $t5 #quotient
	move $a1, $t6
	beqz $t3, first_case
	
##########P-CALCULATION##################################
	
	mul $t0, $t2, $t3 #this is based of the formula on git
	sub $t0, $t1, $t0
	blt $t0, $0, negative #a special case for negaive case
	div $t0, $t8
	mfhi $t0 #new pi
		
	j update_pq
	
negative:
	
	abs $t0, $t0 #gets the absolute value
	div $t0, $t8 #divides by $a1
	li $t7, 0 
	mflo $t7 #loads the quotient in a empty register
	
	addi $t7, $t7, 1 #need to add one
	mul $t7, $t7, $t8 #mult by a1
	sub $t0, $t0, $t7 #subtracts by p
	abs $t0, $t0 #gets absoulte val
	
	j update_pq	

	
first_case:
	#for the case where p = 0
	move $t3, $t4
	move $t4, $t5
	
	j prik_loop
	
	
update_pq:

	#P pushback
	move $t1, $t2
	move $t2, $t0
	
	#Q pushback
	move $t3, $t4
	move $t4, $t5

	j prik_loop
	
finish_prik:
	#one last iteration after remainder is 0
	mul $t0, $t2, $t3
	sub $t0, $t1, $t0
	blt $t0, $0, negativeF
	div $t0, $t8
	mfhi $t0 #new pi
	
	j closing

negativeF:
 	#negative special case for the last iteration
	abs $t0, $t0
	div $t0, $t8
	li $t7, 0
	mflo $t7
	
	addi $t7, $t7, 1
	mul $t7, $t7, $t8
	sub $t0, $t0, $t7
	abs $t0, $t0
	
	j closing
	
closing:

	move $v0, $t0 #moves the result to t0
	
	lw $t7, 28($sp)
	lw $t6, 24($sp)
	lw $t5, 20($sp)
	lw $t4, 16($sp)
	lw $t3, 12($sp)
	lw $t2, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	
	addi $sp,$sp, 32
	
	jr $ra
	

.globl encrypt
encrypt:	
	
	move $t1, $a1
	move $t2, $a2
	li $t4, 0 #counter
	li $t3, 1 #final result
	
	addi $a1, $a1, -1
	addi $a2, $a2, -1
	
	addi $sp, $sp, -16
	sw $a0, 12($sp)
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $ra, 0($sp)
	
	move $a0, $a2
	
	jal lcm #Find Z ( K ) 

	move $a0, $v0
	
	jal pubkExp #find e using K
	
	lw $ra, 0($sp)
	lw $a2, 4($sp)
	lw $a1, 8($sp)
	lw $a0, 12($sp)
	addi $sp, $sp, 16
	
	move $v1, $v0 #resulting
	
	#euclidean modular method
	mul $t6, $t1, $t2 #multiplies t1 and t2
	
	j modular_loop
	
modular_loop:
	
	addi $t4, $t4, 1 #counter (e)
	mul $t3, $t3, $a0 #m = m * c
	div $t3, $t6
	mfhi $t3
	beq $t4, $v0, ending
	
	j modular_loop
ending:
	move $v0, $t3
	jr $ra
	

.globl decrypt
decrypt:
	move $t0, $a2
	move $t1, $a3
	
	move $t5, $a1 #pubk
	
	li $t4, 0
	li $t3, 1
	addi $a2, $a2, -1
	addi $a3, $a3, -1
	
	#find k
	
	addi $sp, $sp, -20
	sw $a0, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a3, 4($sp)
	sw $ra, 0($sp)
	
	#fixes the parameters of lcm
	move $a0, $a2 
	move $a1, $a3
	
	jal lcm
	
	#sets up prikexp call
	move $a0, $t5
	move $a1, $v0
	
	jal prikExp
	
	lw $ra, 0($sp)
	lw $a3, 4($sp)
	lw $a2, 8($sp)
	lw $a1, 12($sp)
	lw $a0, 16($sp)
	addi $sp, $sp, 20
	
	mul $t2, $t0, $t1

	j looppt2
	
looppt2:
	#euclidian modular method again

	addi $t4, $t4, 1
	mul $t3, $t3, $a0
	div $t3, $t2
	mfhi $t3
	beq $t4, $v0, ending2
	j looppt2
	
ending2:

	move $v0, $t3
	jr $ra