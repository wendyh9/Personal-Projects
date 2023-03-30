# author: Wendy Haw

.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
str6: .asciiz "\n"


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	# need to recreate calcSum(sorted, numScores - drop)/(numScores - drop)
	# $v0 = calcSum() + sorted[(len - 1)]
	# $a1 = numScores - 1
	
	div $s4, $v0, $a1						# calcSum(sorted, numScores - drop)/(numScores - drop)
	
	# print string
	li $v0, 4
	la $a0, str5
	syscall
	
	
	move $a0, $s4

	li $v0, 1							# print result
	syscall

	# **********************************************
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	

# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	

	# variables:
		# $a0 = array that will be printed
		# $a1 = numScores
		# $t0 = counter
		# $t1 = temp variable to hold current int to print
		# $t2 = temp variable for various values
	
	li $t0, 0
	la $t1, 0($a0)						# load address of array 

loop:	
	bge $t0, $a1, exitLoop		
	
	#lw $t1, 0($a0)						# load current int
	lw $t2, 0($t1)						# load value of integer at the address of array
	addi $t1, $t1, 4					# advance array pointer
	
	# printing integer
	li $v0, 1							
	move $a0, $t2						# move current int into $a0
	syscall
	
	# printing space
	li $a0, 32							# 32 = ascii value for " "
	li $v0, 11							# print character
	syscall	
	
	addi $t0, $t0, 1					# increment counter
	j loop

exitLoop:
	
	# print new line
	la $a0, str6						# str6 = "\n"
	li $v0, 4							# print string
	syscall
	
	jr $ra								# go back to main	



# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here

	# variables:
		# $a0 = numScores
		# $s1 = orig
		# $s2 = sorted

	li $t0, 0							# reset $t0 to value 0
	li $t1, 0
	li $t2, 0
	
initializeSorted:	
	# variables:
		# $t0 = counter
		# $t1 = orig[i]
		# $t2 = sorted[i]

	bge $t0, $a0, exitInitializeSorted
	
	
	add $t1, $t1, $s1					# orig[i]
	add $t2, $t2, $s2					# sorted[i]

	# sorted[i] = orig[i]
	lw $t1, 0($t1)						
	sw $t1, 0($t2)
	
	addi $t0, $t0, 1					# increment counter
	sll $t1, $t0, 2				# increment address in $t1 by 4
	sll $t2, $t0, 2					# incrememnt address in $t2 by 4
	j initializeSorted

exitInitializeSorted:
	# variables:
		# $t0 = temp variable for various values
		# $t1 = counter for outerLoop
		# $t2 = len - 1	


	li $t0, 0							# reset $t0 to value 0
	addi $t2, $a0, -1					# compute len - 1 and store in $t2

outerLoop:
	# variables:
		# $t0 = int i
		# $t1 = int j
		# $t2 = len - 1
		# $t3 = maxIndex
		# $t4 = temp variable for various values
	
	li $t1, 0							# reset $t1 to value 0 for each iteration of i
	bge $t0, $t2, exitOuterLoop
	add $t3, $t0, $zero					# maxIndex = i

	addi $t1, $t0, 1 					# j = i + 1 

innerLoop:
	# variables:
		# $t4 = sorted[j]
		# $t5 = sorted[maxIndex]

	bge $t1, $a0, swap					# j < len

	# if (sorted[j] > sorted[maxIndex])
	sll $t4, $t1, 2						# j * 4
	add $t4, $t4, $s2					# sorted[j]
	lw $t4, 0($t4)						# load sorted[j] into $t4 
	
	sll $t5, $t3, 2						# maxIndex * 4
	add $t5, $t5, $s2					# sorted[maxIndex]
	lw $t5, 0($t5)						# load sorted[maxIndex] into $t5

	ble $t4, $t5, exitInnerLoop

	add $t3, $t1, $zero					# maxIndex = j

exitInnerLoop:
	addi $t1, $t1, 1					# increment j
	j innerLoop

swap:
	# variables:
		# $t6 = sorted[maxIndex] -> sorted[i]
		# $t7 = sorted[i] -> sorted[maxIndex]
		# $t8 = temp
		# $s2 = sorted 
		# $s3 = old sorted[maxIndex]

	# temp = sorted[maxIndex]
	sll $t6, $t3, 2						# maxIndex * 4
	add $t6, $t6, $s2					# sorted[maxIndex]
	lw $s3, 0($t6)						# load value of sorted[maxIndex] into $s3
	add $t8, $s3, $zero					# temp = sorted[maxIndex]

	# sorted[maxIndex] = sorted[i]
	sll $t7, $t0, 2						# i * 4
	add $t7, $t7, $s2					# sorted[i]
	lw $s4, 0($t7)						# load value of sorted[i] into $s4
	sw $s4, 0($t6)						# sorted[maxIndex] = sorted[i]

	# sorted[i] = temp
	sw $t8, 0($t7)						# store value of temp in sorted
	
	addi $t0, $t0, 1					# increment i
	
	j outerLoop

exitOuterLoop:	
	jr $ra



# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
	# Your implementation of calcSum here
	
	# variables:
		# a0 = int* arr = sorted
		# a1 = len = numScores - drop 
		# $t0 = calcSum()
		# $t1 = points to sorted[(len - 1)] (recursion)
		# $t2 = loads value of sorted[(len - 1)] (recursion)
		# $t3 = points to sorted[(len - 1)] (exitRecursion)
		# $t4 = loads value of sorted[(len - 1)] (exitRecursion)
		# $v0 = return value

	li $t0, 0							# reset $t0 to 0
	li $t1, 0
	li $t2, 0

	addi $sp, $sp, -8					# enough space to store 2 variables on stack
	sw $ra, 0($sp)						# store return address
	sw $a1, 4($sp)						# store numScores - drop 

	# prep for calcSum(sorted, len - 1) and arr[len - 1]
	addi $a1, $a1, -1

recursion:
	ble $a1, $zero, exitRecursion

	addi $a1, $a1, -1					# len - 1
	sll $t1, $a1, 2						# (len - 1) * 4
	add $t1, $t1, $a0					# array pointer points to sorted[(len - 1)]

	lw $t2, 0($t1)						# load value of sorted[(len - 1)]
	add $t0, $t0, $t2					# calcSum() + sorted[(len - 1)]

	jal recursion

exitRecursion:
	lw $t3, 4($sp) 						# load original value of len (value of len passed into function)

	addi $t3, $t3, -1					# len - 1
	sll $t3, $t3, 2 					# (len - 1) * 4
	add $t3, $t3, $a0 					# array pointer points to sorted[(len - 1)]
	lw $t4, 0($t3)						# load value of sorted[(len - 1)]

	add $v0, $t0, $t4 					# calcSum() + sorted[(len - 1)]

	# restore stored variables on stack
	lw $ra, 0($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 8					# pop $ra and $a1 off stack
	jr $ra