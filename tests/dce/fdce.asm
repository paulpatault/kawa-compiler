.text
	beqz $a0, init_end
	lw $a0, 0($a1)
	jal atoi
init_end:
	sw $v0, 0($sp)
	subi $sp, $sp, 4
	jal main
	li $v0, 10
	syscall
main:
main_g_12:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
main_g_11:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
main_g_10:
	addi $fp, $sp, 8
main_g_9:
	addi $sp, $sp, 0
main_5:
main_4:
	li $t2, 0
main_3:
	move $v0, $t2
main_g_4:
	addi $sp, $fp, -8
main_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
main_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
main_g_1:
	jr $ra
StdLib_constructor:
StdLib_constructor_g_8:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
StdLib_constructor_g_7:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
StdLib_constructor_g_6:
	addi $fp, $sp, 8
StdLib_constructor_g_5:
	addi $sp, $sp, 0
StdLib_constructor_4:
	li $t2, 0
StdLib_constructor_3:
	bnez $t2, StdLib_constructor_2
	li $a0, 10
	li $v0, 11
	syscall
	syscall
	la $a0, exit_on_assert
	li $v0, 4
	syscall
	li $a0, 3
	li $v0, 1
	syscall
	li $v0, 10
	syscall
StdLib_constructor_2:
	li $t2, 0
StdLib_constructor_1:
	move $v0, $t2
StdLib_constructor_g_4:
	addi $sp, $fp, -8
StdLib_constructor_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_constructor_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_constructor_g_1:
	jr $ra
StdLib_max:
StdLib_max_g_16:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
StdLib_max_g_15:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
StdLib_max_g_14:
	addi $fp, $sp, 8
StdLib_max_g_13:
	addi $sp, $sp, 0
StdLib_max_10:
	move $t2, $a0
StdLib_max_9:
	move $t3, $a1
StdLib_max_8:
	slt $t5, $t3, $t2
StdLib_max_7:
	beqz $t5, StdLib_max_6
StdLib_max_4:
	move $t4, $a0
StdLib_max_3:
	move $v0, $t4
StdLib_max_g_12:
	addi $sp, $fp, -8
StdLib_max_g_11:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_max_g_10:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_max_g_9:
	jr $ra
StdLib_max_6:
	move $t4, $a1
StdLib_max_5:
	move $v0, $t4
StdLib_max_g_4:
	addi $sp, $fp, -8
StdLib_max_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_max_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_max_g_1:
	jr $ra
StdLib_min:
StdLib_min_g_16:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
StdLib_min_g_15:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
StdLib_min_g_14:
	addi $fp, $sp, 8
StdLib_min_g_13:
	addi $sp, $sp, 0
StdLib_min_10:
	move $t2, $a1
StdLib_min_9:
	move $t3, $a0
StdLib_min_8:
	slt $t5, $t3, $t2
StdLib_min_7:
	beqz $t5, StdLib_min_6
StdLib_min_4:
	move $t4, $a0
StdLib_min_3:
	move $v0, $t4
StdLib_min_g_8:
	addi $sp, $fp, -8
StdLib_min_g_7:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_min_g_6:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_min_g_5:
	jr $ra
StdLib_min_6:
	move $t4, $a1
StdLib_min_5:
	move $v0, $t4
StdLib_min_g_12:
	addi $sp, $fp, -8
StdLib_min_g_11:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_min_g_10:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_min_g_9:
	jr $ra
StdLib_pow:
StdLib_pow_g_41:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_40:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_39:
	addi $fp, $sp, 8
StdLib_pow_g_38:
	addi $sp, $sp, 0
StdLib_pow_20:
	move $t2, $a1
StdLib_pow_19:
	li $t3, 0
StdLib_pow_18:
	sle $t8, $t3, $t2
StdLib_pow_17:
	bnez $t8, StdLib_pow_16
	li $a0, 10
	li $v0, 11
	syscall
	syscall
	la $a0, exit_on_assert
	li $v0, 4
	syscall
	li $a0, 25
	li $v0, 1
	syscall
	li $v0, 10
	syscall
StdLib_pow_16:
	li $t8, 0
StdLib_pow_15:
	move $t4, $a1
StdLib_pow_14:
	seq $t8, $t4, $t8
StdLib_pow_13:
	beqz $t8, StdLib_pow_12
StdLib_pow_4:
	li $t2, 1
StdLib_pow_3:
	move $v0, $t2
StdLib_pow_g_8:
	addi $sp, $fp, -8
StdLib_pow_g_7:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_pow_g_6:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_pow_g_5:
	jr $ra
StdLib_pow_12:
	move $t6, $a0
StdLib_pow_11:
	li $t8, 1
StdLib_pow_10:
	move $t5, $a1
StdLib_pow_9:
	sub $t8, $t5, $t8
StdLib_pow_8:
StdLib_pow_g_37:
	sw $t8, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_36:
	sw $t4, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_35:
	sw $t2, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_34:
	sw $t7, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_33:
	sw $t3, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_32:
	sw $t5, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_31:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_30:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_29:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_28:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
StdLib_pow_g_27:
	move $a1, $t8
StdLib_pow_g_26:
	move $a0, $t6
StdLib_pow_g_25:
	jal StdLib_pow
StdLib_pow_g_24:
	addi $sp, $sp, 0
StdLib_pow_g_23:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
StdLib_pow_g_22:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
StdLib_pow_g_21:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
StdLib_pow_g_20:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
StdLib_pow_g_19:
	addi $sp, $sp, 4
	lw $t5, 0($sp)
StdLib_pow_g_18:
	addi $sp, $sp, 4
	lw $t3, 0($sp)
StdLib_pow_g_17:
	addi $sp, $sp, 4
	lw $t7, 0($sp)
StdLib_pow_g_16:
	addi $sp, $sp, 4
	lw $t2, 0($sp)
StdLib_pow_g_15:
	addi $sp, $sp, 4
	lw $t4, 0($sp)
StdLib_pow_g_14:
	addi $sp, $sp, 4
	lw $t8, 0($sp)
StdLib_pow_g_13:
	move $t8, $v0
StdLib_pow_7:
	move $t7, $a0
StdLib_pow_6:
	mul $t2, $t7, $t8
StdLib_pow_5:
	move $v0, $t2
StdLib_pow_g_4:
	addi $sp, $fp, -8
StdLib_pow_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
StdLib_pow_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
StdLib_pow_g_1:
	jr $ra
A_constructor:
A_constructor_g_8:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
A_constructor_g_7:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
A_constructor_g_6:
	addi $fp, $sp, 8
A_constructor_g_5:
	addi $sp, $sp, 0
A_constructor_2:
	li $t2, 0
A_constructor_1:
	move $v0, $t2
A_constructor_g_4:
	addi $sp, $fp, -8
A_constructor_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
A_constructor_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
A_constructor_g_1:
	jr $ra
A_meth:
A_meth_g_8:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
A_meth_g_7:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
A_meth_g_6:
	addi $fp, $sp, 8
A_meth_g_5:
	addi $sp, $sp, 0
A_meth_4:
	li $t2, 1
A_meth_3:
	beqz $t2, A_meth_2
	b A_meth_4
A_meth_2:
	li $t2, 0
A_meth_1:
	move $v0, $t2
A_meth_g_4:
	addi $sp, $fp, -8
A_meth_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
A_meth_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
A_meth_g_1:
	jr $ra
#built-in atoi
atoi:
	li $v0, 0
atoi_loop:
	lbu $t0, 0($a0)
	beqz $t0, atoi_end
	addi $t0, $t0, -48
	bltz $t0, atoi_error
	bge $t0, 10, atoi_error
	mul $v0, $v0, 10
	add $v0, $v0, $t0
	addi $a0, $a0, 1
	b atoi_loop
atoi_error:
	li $v0, 10
	syscall
atoi_end:
	jr $ra
.data
descr_A:
	.word 0
	.word A_constructor
	.word A_meth
descr_StdLib:
	.word 0
	.word StdLib_constructor
	.word StdLib_max
	.word StdLib_min
	.word StdLib_pow
exit_on_assert:
	.asciiz ">>> Échec d'assertion en ligne : "