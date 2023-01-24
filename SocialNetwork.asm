############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

.globl create_network
create_network:
#Network* create_network(int I, int J)
addi $sp,$sp,-24
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
#Saves some S registers to use
bltz $a0, create_error #if I is  negative
bltz $a1, create_error #if J is negative
move $s0, $a0 #stores I
move $s1, $a1 #stores J
add $t0, $s0, $s1 # adds the total 
addi $t0, $t0, 4 #first 4 bytes
move $t3, $t0
li $t4, 4
mul $t0, $t0, $t4
#t0 holds the amount of bytes to be allocated
move $a0, $t0
li $v0, 9
syscall
#creates all the bytes needed


move $s3, $v0  #STORAGE FOR THE GRAPH
sw $s0, 0($s3)
sw $s1, 4($s3)

addi $s3, $s3, 8
li $t1, 0 #counter
li $t2, 0 #temp to keep track of btyes
addi $t1, $t1, 2
addi $t2, $t2, 8
 
#Start Loop
create_network_loop:
beq $t1, $t3, terminate_create

sw $0, 0($s3) 
addi $t1, $t1, 1
addi $t2, $t2, 4 #adds to byte counter 
addi $s3, $s3, 4 #moves the address

j create_network_loop



create_error:
li $t0, -1
move $v0, $t0 #moves -1 into v0, Prep for termination

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24


terminate_create:


lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24
  jr $ra

.globl add_person##############################################################################################
add_person:
addi $sp,$sp,-24
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
#Node* add_person(Network* ntwrk, char* name)
#address of network in a0
#name is in a1

#Storage of things
move $s0, $a0 #S0 now holds the network
move $t8, $a0 #saves a blank copy for reference if needed
move $s4, $a0
move $s1, $a1, #a1 now holds the name

#getting total number of bytes and such

lw $s2, 0($s0)
lw $s3, 4($s0)
add $t0, $s2, $s3 # adds the total 
addi $t0, $t0, 4 #first 4 bytes
li $t1, 4
mul $t0, $t0, $t1 #t0 holds the total number of bytes in the struct


#Validation Checks
lw $t1, 8($s0)
beq $s2, $t1, add_error  #Check is the network is full




lbu $t1, 0($s1) 
beqz $t1, add_error #Check if the name is empty

	#check if the network is empty so you can just add it
	lw $t1, 16($s0)
	beqz $t1, begin_add
	
	#Else check everything else

lw $t1, 8($s0) #should be the number of nodes 
move $t2, $0 #counter for the number of nodes checked
addi $s0, $s0, 16

same_name_check:

	move $s1, $a1 #reset the name
	beq $t1, $t2, begin_add #fix ?
	
	lw $t3, 0($s0) #first node
	addi $t3, $t3, 4

	
	name_loop:
		lb $t5, 0($s1) #gets the char from the name
		lb $t4, 0($t3) #loads the name ?
		beqz $t5, check_null1
		beqz $t4, pause #goes back cuz not same
		bne $t4, $t5, pause 
		addi $s1, $s1, 1
		addi $t3, $t3, 1
		j name_loop
		
check_null1:
	beqz $t4, add_error
	j pause
	
pause:
	addi $s0, $s0, 4
	addi $t2, $t2, 1
	j same_name_check

#Validation Checks

#start the add
begin_add:
move $s0, $t8
li $t5, 0 #counter
#first find the length of the string
name_length:
lb $t0, 0($s1) #Length is in t5
beqz $t0, cont_add
addi $t5, $t5, 1
addi $s1, $s1, 1
j name_length
#at this point length is known and will require 4 bytes because it is a word! 
cont_add:
#first take the length and add 4 to it, that'll be the number of bytes you need for the node, save this number
#next add 4 to the memory and then start filling in the characters, including the null char
#then put node base address into the right offset, facts
#set the length and name in node
move $s1, $a1 #reset name
addi $s5, $t5, 5
move $a0, $s5
li $v0, 9
syscall #makes the node with the right amount of bytes, i think
move $t6, $v0 #t6 will be the node
sw $t5, 0($t6) #store the length in the first 4 bytes
addi $t6, $t6, 4
li $t7, 0 #counter
addi $s5, $s5, -4

store_name:
beq $t7, $s5, insert
lbu $t9, 0($s1)
sb $t9, 0($t6)
addi $s1, $s1, 1
addi $t6, $t6, 1
addi $t7, $t7, 1
j store_name

insert:
#insert v0
move $s0, $t8 #s0 is the network, now find the next available space
addi $s0, $s0, 16

insert_loop:

lw $t9, 0($s0)
beqz $t9, insert_final
addi $s0, $s0, 4
j insert_loop



insert_final:

sw $v0, 0($s0)
lw $t2, 8($t8)
addi $t2, $t2, 1
sw $t2, 8($t8)

j terminate_add


add_error:
li $t9, -1
move $v0, $t9
move $v1, $t9
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24
  jr $ra


terminate_add:
move $v0, $s4
li $t9, 1
move $v1, $t9

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24
  jr $ra

.globl get_person
get_person:
#Node* get_person(Network* network, char* name)
addi $sp,$sp,-24
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
#I think this function is essentially what I did in a loop in add_person but okay

move $s0, $a0
move $s1, $a1
li $t0, 0 
li $t1, 0 #will be counter i assume
li $t2, 0
li $t3, 0
li $t4, 0
li $t5, 0
#^in case they are some other values from diff functions
lw $t2, 8($s0) #number of nodes in graph duhhh
addi $s0, $s0, 16 #gets to the nodes
get_loop:

	move $s1, $a1 #reset the name
	beq $t1, $t2, not_found #checked every element
	
	lw $t3, 0($s0) #node
	move $t6, $t3
	addi $t3, $t3, 4

	
	scanner:
		lb $t5, 0($s1) #gets the char from the name
		lb $t4, 0($t3) #loads char from name in node
		beqz $t5, null
		beqz $t4, reset #goes back cuz not same
		bne $t4, $t5, reset 
		addi $s1, $s1, 1
		addi $t3, $t3, 1
		j scanner
		
null:
	beqz $t4, return
	j reset
	
reset:
	addi $s0, $s0, 4
	addi $t1, $t1, 1
	j get_loop


return:

move $v0, $t6
li $t5, 1
move $v1, $t5

j get_terminate

not_found:
li $t9, -1
move $v0, $t9
move $v1, $t9

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24
jr $ra

get_terminate:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
addi $sp,$sp,24
 jr $ra

.globl add_relation
add_relation:
#Network* add_relation(Network* ntwrk, char* name2, char* name2, int relation_type)
addi $sp,$sp,-32
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)

move $s0, $a0
move $s1, $a1
move $s2, $a2
move $s3, $a3

#VALIDATION CHECKS######################################################
bltz $a3, failed
li $t9, 3						#Checks the int relation value 0 > x > 3
bgt $a3, $t9, failed

lw $t0, 4($a0)
lw $t1, 12($a0)				#Checks if network is at capcity in terms of edges
beq $t0, $t1, failed

same_name_loop:
lb $t0, 0($s1)
lb $t1, 0($s2)
beqz $t0, check_zero
beqz $t1, continue_checks
bne $t1, $t0, continue_checks			#Checks for the same name
addi $s1, $s1, 1
addi $s2, $s2, 1
j same_name_loop

check_zero:
beqz $t1, failed
j continue_checks

continue_checks:
addi $sp, $sp, -12
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $ra, 8($sp)

jal get_person #checks the first name

lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12

li $t1, -1
beq $t1, $v1, failed #if it wasnt found then its clipped

move $s6, $v0 #saves NAME1
##################################### NAME 2 CHECK
move $t0, $a1
move $a1, $a2 #moves name 2 into a1 for get person

addi $sp, $sp, -16
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $ra, 8($sp)
sw $t0, 12($sp)

jal  get_person #name 2

lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
lw $t0, 12($sp)
addi $sp, $sp, 16

li $t1, -1
beq $t1, $v1, failed #name 2 wasnt found, so just exit the program L
move $s7, $v0 #Saves NAME 2
move $a1, $t0 #restores the name1 back into a1

j final_check

final_check:
lw $t0, 12($s0)
beqz $t0, start_add

lw $t0, 0($s0) #Max nodes
lw $t1, 4($s0) #Max edges
lw $t9, 12($s0)
addi $s0, $s0, 16 #goes to first node
li $t2, 4
mul $t2, $t0, $t2 #t2 is number of bytes to skip
add $s0, $s0, $t2 #should set the offset to the first node in the EDGE array
li $t7, 0 #counter

#$t1 is the max number of edges !!!
final_loop:
#check first node -first name
#check first node - second name if not first name
#check second node - first name 
#check second node - second name if not first name

	move $s1, $a1 #reset NAME 1
	beq $t7, $t9, start_add #checked every EDGE NODE
	lw $t3, 0($s0) #first node address
	lw $t3, 0($t3)
	addi $t3, $t3, 4

	
	
	inner_loop:
		lb $t5, 0($s1) #gets the char from NAME 1
		lb $t4, 0($t3) #first char in name of NODE 1
		beqz $t5, precheck #IF NAME ONE IS NULL
		beqz $t4, check_node1name2 #IF NODE 1 NAME IS NULL
		bne $t4, $t5, check_node1name2 #branch to check NAME 2 with NAME 1 on this part
		addi $s1, $s1, 1 #else move name 1 up
		addi $t3, $t3, 1 #move node 1 name up
		j inner_loop #jump back
		
precheck:
	beqz $t4, check_node2name2 # Node 1 name is also null which means they are the same, so laslty check Node 2 with Name 2
	#do this
	j check_node1name2 #jump to check if node 1 name and name 2 are the same

check_node2name2:
	
	move $s2, $a2 #restore NAME 2
	lw $t3, 0($s0)
	lw $t3, 4($t3)
	addi $t3, $t3, 4
	
	inner_loop4:
	lb $t5, 0($s2) #name 2
	lb $t4, 0($t3) #Node 2
	beqz $t5, precheck4
	beqz $t4, run_it_back
	addi $t3, $t3, 1
	addi $s2, $s2, 1
	j inner_loop4
precheck4:
	bnez $t4, run_it_back
	j failed

check_node1name2:
	
	move $s2, $a2 #restores NAME 2
	lw $t3, 0($s0) 
	lw $t3, 0($t3)
	addi $t3, $t3, 4 #restores NODE 1
	
	inner_loop2:
	lb $t5, 0($s2) #loads NAME 2
	lb $t4, 0($t3) #loads NODE 1
	beqz $t5, precheck2
	beqz $t4, run_it_back
	bne $t5, $t4, run_it_back
	addi $t3, $t3, 1
	addi $s2, $s2, 1

	j inner_loop2
	
precheck2:
	bnez $t4, run_it_back
	
	#else check NODE 2 with NAME 1
	j check_node2name1


check_node2name1:

	move $s1, $a1 #restore NAME 1
	lw $t3, 0($s0)
	lw $t3, 4($t3)
	addi $t3, $t3, 4
	
	inner_loop3:
	lb $t5, 0($s1) #NAME 1
	lb $t4, 0($t3) #NODE 2
	beqz $t5, precheck3
	beqz $t4, run_it_back
	bne $t5, $t4, run_it_back
	addi $t3, $t3, 1
	addi $s1, $s1, 1
	j inner_loop3
	
precheck3:
bnez $t4, run_it_back

j failed

run_it_back:

addi $t7, $t7, 1
addi $s0, $s0, 4

j final_loop

#VALIDATION CHECKS######################################################
start_add:
#$s6 = ref to node with name 1
#$s7 = ref to node with name 2

#Make the Node and save the address
#Insert the ref addresses and Int value
#Find the place to store it
#Store it and return the network
#EZ
move $t8, $a0
li $a0, 12
li $v0, 9
syscall #Instantiates EDGE node in heap
move $a0, $t8 #network back

move $t7, $v0

sw $s6, 0($t7)
sw $s7, 4($t7)
sw $a3, 8($t7)

lw $t3, 0($a0)
lw $t4, 12($a0)
li $t0, 4
mul $t3, $t3, $t0 #bytes currenlty occupied by nodes
mul $t4, $t4, $t0 #bytes ' ' ' ' ' edge nodes

addi $t8, $t8, 16
add $t8, $t8, $t3
add $t8 $t8, $t4

sw $v0, 0($t8)

lw $t4, 12($a0)
addi $t4, $t4, 1
sw $t4, 12($a0)

j success

success:

move $v0, $a0
li $t0, 1
move $v1, $t0

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
addi $sp,$sp, 32
jr $ra


failed:
li $t9, -1
move $v0, $t9
move $v1, $t9
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
addi $sp,$sp,32
 jr $ra

.globl get_distant_friends
get_distant_friends:
#FriendNode* get_distant_friends(Network* ntwrk, char* name)
addi $sp,$sp,-32
sw $s0,0($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6, 24($sp)
sw $s7, 28($sp)

move $s0, $a0
move $s1, $a1

#first check if person exist
addi $sp, $sp, -12
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $ra, 8($sp)


jal  get_person 

lw $a0, 0($sp)
lw $a1, 4($sp)
lw $ra, 8($sp)
addi $sp, $sp, 12

bltz $v0, no_exist #branch if get person resulted in -1 in v0
move $t0, $v0 #Node with "name" is now in $t0

#now check if "name" has no distant friends
	#1. get the ref of the node (done at this point $t0)
	#2. loop through edges and see if node matches 
	#3. save all the nodes that are edges with the name node and are immediate friends by storing the address in a register

lw $t1, 0($s0) #Max nodes
lw $t2, 4($s0) #Max edges
lw $t9, 12($s0)
addi $s0, $s0, 16 #goes to first node
li $t3, 4
mul $t3, $t2, $t3 #t2 is number of bytes to skip
add $s0, $s0, $t3#should set the offset to the first node in the EDGE array
 #The above code was to adjust the struct to first edge node
 #now find the direct friends, allocate memory for them and check them !
 li $t7, 0 #counter for number of direct friends 
 li $t6, 0 #counter for amount of edges, should be compared to $t9
 
 #allocate an array basically
 li $t3, 4
 mul $t2, $t3, $t1 #bytes needed for all the nodes
 move $s6, $t2
 move $a0, $t2
 move $a0, $s6
 li $v0, 9
 syscall
 move $a0, $t2
 move $s3, $v0 #saves the beginning of the array
 move $s4, $v0# used to adjust
 
 edge_loop:
 	
	beq $t9, $t6, check_distant0
	addi $t6, $t6, 1

 	j edge_loop
 	
check_distant0:
 
li $t1, -1
move $v0, $t1

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
addi $sp,$sp,32
 jr $ra

 	
 
	
no_exist:
li $t1, -2
move $v0, $t1 #moves -1 into $v0

lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6, 24($sp)
lw $s7, 28($sp)
addi $sp,$sp,32
 jr $ra