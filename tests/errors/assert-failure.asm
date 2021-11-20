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
main_g_271:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
main_g_270:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
main_g_269:
	addi $fp, $sp, 8
main_g_268:
	addi $sp, $sp, 0
main_44:
	li $t6, 4
main_43:
	la $t1, x
	sw $t6, 0($t1)
main_42:
	li $s5, -2
main_41:
	la $t1, y
	sw $s5, 0($t1)
main_40:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_159:
	li $a0, 109
main_g_158:
	li $v0, 11
main_g_157:
	syscall
main_g_156:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_155:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_154:
	li $a0, 97
main_g_153:
	li $v0, 11
main_g_152:
	syscall
main_g_151:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_150:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_149:
	li $a0, 120
main_g_148:
	li $v0, 11
main_g_147:
	syscall
main_g_146:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_145:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_144:
	li $a0, 40
main_g_143:
	li $v0, 11
main_g_142:
	syscall
main_g_141:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_39:
	la $t7, x
	lw $t7, 0($t7)
main_38:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_253:
	li $v0, 1
main_g_252:
	move $a0, $t7
main_g_251:
	syscall
main_g_250:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_37:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_168:
	li $a0, 44
main_g_167:
	li $v0, 11
main_g_166:
	syscall
main_g_165:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_36:
	la $t8, y
	lw $t8, 0($t8)
main_35:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_164:
	li $v0, 1
main_g_163:
	move $a0, $t8
main_g_162:
	syscall
main_g_161:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_34:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_9:
	li $a0, 41
main_g_8:
	li $v0, 11
main_g_7:
	syscall
main_g_6:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_5:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_4:
	li $a0, 61
main_g_3:
	li $v0, 11
main_g_2:
	syscall
main_g_1:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_33:
	la $s0, x
	lw $s0, 0($s0)
main_32:
	la $t9, y
	lw $t9, 0($t9)
main_31:
main_g_88:
	sw $s4, 0($sp)
	subi $sp, $sp, 4
main_g_87:
	sw $s5, 0($sp)
	subi $sp, $sp, 4
main_g_86:
	sw $t6, 0($sp)
	subi $sp, $sp, 4
main_g_85:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_84:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_83:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_82:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_81:
	sw $t4, 0($sp)
	subi $sp, $sp, 4
main_g_80:
	sw $s2, 0($sp)
	subi $sp, $sp, 4
main_g_79:
	sw $t3, 0($sp)
	subi $sp, $sp, 4
main_g_78:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_77:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_76:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_75:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_74:
	move $a1, $t9
main_g_73:
	move $a0, $s0
main_g_72:
	jal Math_max
main_g_71:
	addi $sp, $sp, 0
main_g_70:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_69:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_68:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_67:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_66:
	addi $sp, $sp, 4
	lw $t3, 0($sp)
main_g_65:
	addi $sp, $sp, 4
	lw $s2, 0($sp)
main_g_64:
	addi $sp, $sp, 4
	lw $t4, 0($sp)
main_g_63:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_62:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_61:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_60:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_59:
	addi $sp, $sp, 4
	lw $t6, 0($sp)
main_g_58:
	addi $sp, $sp, 4
	lw $s5, 0($sp)
main_g_57:
	addi $sp, $sp, 4
	lw $s4, 0($sp)
main_g_56:
	move $s5, $v0
main_30:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_14:
	li $v0, 1
main_g_13:
	move $a0, $s5
main_g_12:
	syscall
main_g_11:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_29:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_111:
	li $a0, 10
main_g_110:
	li $v0, 11
main_g_109:
	syscall
main_g_108:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_28:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_248:
	li $a0, 109
main_g_247:
	li $v0, 11
main_g_246:
	syscall
main_g_245:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_244:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_243:
	li $a0, 105
main_g_242:
	li $v0, 11
main_g_241:
	syscall
main_g_240:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_239:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_238:
	li $a0, 110
main_g_237:
	li $v0, 11
main_g_236:
	syscall
main_g_235:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_234:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_233:
	li $a0, 40
main_g_232:
	li $v0, 11
main_g_231:
	syscall
main_g_230:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_27:
	la $s1, x
	lw $s1, 0($s1)
main_26:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_173:
	li $v0, 1
main_g_172:
	move $a0, $s1
main_g_171:
	syscall
main_g_170:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_25:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_106:
	li $a0, 44
main_g_105:
	li $v0, 11
main_g_104:
	syscall
main_g_103:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_24:
	la $s2, y
	lw $s2, 0($s2)
main_23:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_46:
	li $v0, 1
main_g_45:
	move $a0, $s2
main_g_44:
	syscall
main_g_43:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_22:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_262:
	li $a0, 41
main_g_261:
	li $v0, 11
main_g_260:
	syscall
main_g_259:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_258:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_257:
	li $a0, 61
main_g_256:
	li $v0, 11
main_g_255:
	syscall
main_g_254:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_21:
	la $s4, x
	lw $s4, 0($s4)
main_20:
	la $s3, y
	lw $s3, 0($s3)
main_19:
main_g_33:
	sw $s4, 0($sp)
	subi $sp, $sp, 4
main_g_32:
	sw $s5, 0($sp)
	subi $sp, $sp, 4
main_g_31:
	sw $t6, 0($sp)
	subi $sp, $sp, 4
main_g_30:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_29:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_28:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_27:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_26:
	move $a1, $s3
main_g_25:
	move $a0, $s4
main_g_24:
	jal Math_min
main_g_23:
	addi $sp, $sp, 0
main_g_22:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_21:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_20:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_19:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_18:
	addi $sp, $sp, 4
	lw $t6, 0($sp)
main_g_17:
	addi $sp, $sp, 4
	lw $s5, 0($sp)
main_g_16:
	addi $sp, $sp, 4
	lw $s4, 0($sp)
main_g_15:
	move $t6, $v0
main_18:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_92:
	li $v0, 1
main_g_91:
	move $a0, $t6
main_g_90:
	syscall
main_g_89:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_17:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_50:
	li $a0, 10
main_g_49:
	li $v0, 11
main_g_48:
	syscall
main_g_47:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_16:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_139:
	li $a0, 112
main_g_138:
	li $v0, 11
main_g_137:
	syscall
main_g_136:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_135:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_134:
	li $a0, 111
main_g_133:
	li $v0, 11
main_g_132:
	syscall
main_g_131:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_130:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_129:
	li $a0, 119
main_g_128:
	li $v0, 11
main_g_127:
	syscall
main_g_126:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_125:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_124:
	li $a0, 40
main_g_123:
	li $v0, 11
main_g_122:
	syscall
main_g_121:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_15:
	la $t2, x
	lw $t2, 0($t2)
main_14:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_267:
	li $v0, 1
main_g_266:
	move $a0, $t2
main_g_265:
	syscall
main_g_264:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_13:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_41:
	li $a0, 44
main_g_40:
	li $v0, 11
main_g_39:
	syscall
main_g_38:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_12:
	la $t3, y
	lw $t3, 0($t3)
main_11:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_55:
	li $v0, 1
main_g_54:
	move $a0, $t3
main_g_53:
	syscall
main_g_52:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_10:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_101:
	li $a0, 41
main_g_100:
	li $v0, 11
main_g_99:
	syscall
main_g_98:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_97:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_96:
	li $a0, 61
main_g_95:
	li $v0, 11
main_g_94:
	syscall
main_g_93:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_9:
	la $t5, x
	lw $t5, 0($t5)
main_8:
	la $t4, y
	lw $t4, 0($t4)
main_7:
main_g_224:
	sw $s4, 0($sp)
	subi $sp, $sp, 4
main_g_223:
	sw $s5, 0($sp)
	subi $sp, $sp, 4
main_g_222:
	sw $t6, 0($sp)
	subi $sp, $sp, 4
main_g_221:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_220:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_219:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_218:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_217:
	sw $t4, 0($sp)
	subi $sp, $sp, 4
main_g_216:
	sw $s2, 0($sp)
	subi $sp, $sp, 4
main_g_215:
	sw $t3, 0($sp)
	subi $sp, $sp, 4
main_g_214:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_213:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_212:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_211:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_210:
	sw $s3, 0($sp)
	subi $sp, $sp, 4
main_g_209:
	sw $t2, 0($sp)
	subi $sp, $sp, 4
main_g_208:
	sw $t8, 0($sp)
	subi $sp, $sp, 4
main_g_207:
	sw $t9, 0($sp)
	subi $sp, $sp, 4
main_g_206:
	sw $s1, 0($sp)
	subi $sp, $sp, 4
main_g_205:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
main_g_204:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
main_g_203:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
main_g_202:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_201:
	move $a1, $t4
main_g_200:
	move $a0, $t5
main_g_199:
	jal Math_pow
main_g_198:
	addi $sp, $sp, 0
main_g_197:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_196:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_195:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_194:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_193:
	addi $sp, $sp, 4
	lw $s1, 0($sp)
main_g_192:
	addi $sp, $sp, 4
	lw $t9, 0($sp)
main_g_191:
	addi $sp, $sp, 4
	lw $t8, 0($sp)
main_g_190:
	addi $sp, $sp, 4
	lw $t2, 0($sp)
main_g_189:
	addi $sp, $sp, 4
	lw $s3, 0($sp)
main_g_188:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_187:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_186:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_185:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_184:
	addi $sp, $sp, 4
	lw $t3, 0($sp)
main_g_183:
	addi $sp, $sp, 4
	lw $s2, 0($sp)
main_g_182:
	addi $sp, $sp, 4
	lw $t4, 0($sp)
main_g_181:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_g_180:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
main_g_179:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
main_g_178:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
main_g_177:
	addi $sp, $sp, 4
	lw $t6, 0($sp)
main_g_176:
	addi $sp, $sp, 4
	lw $s5, 0($sp)
main_g_175:
	addi $sp, $sp, 4
	lw $s4, 0($sp)
main_g_174:
	move $t2, $v0
main_6:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_120:
	li $v0, 1
main_g_119:
	move $a0, $t2
main_g_118:
	syscall
main_g_117:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_5:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
main_g_228:
	li $a0, 10
main_g_227:
	li $v0, 11
main_g_226:
	syscall
main_g_225:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
main_4:
	li $t2, 0
main_3:
	move $v0, $t2
main_g_37:
	addi $sp, $fp, -8
main_g_36:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
main_g_35:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
main_g_34:
	jr $ra
Math_constructor:
Math_constructor_g_8:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
Math_constructor_g_7:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
Math_constructor_g_6:
	addi $fp, $sp, 8
Math_constructor_g_5:
	addi $sp, $sp, 0
Math_constructor_2:
	li $t2, 0
Math_constructor_1:
	move $v0, $t2
Math_constructor_g_4:
	addi $sp, $fp, -8
Math_constructor_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_constructor_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_constructor_g_1:
	jr $ra
Math_max:
Math_max_g_16:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
Math_max_g_15:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
Math_max_g_14:
	addi $fp, $sp, 8
Math_max_g_13:
	addi $sp, $sp, 0
Math_max_10:
	move $t2, $a0
Math_max_9:
	move $t3, $a1
Math_max_8:
	slt $t5, $t3, $t2
Math_max_7:
	beqz $t5, Math_max_6
Math_max_4:
	move $t4, $a0
Math_max_3:
	move $v0, $t4
Math_max_g_4:
	addi $sp, $fp, -8
Math_max_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_max_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_max_g_1:
	jr $ra
Math_max_6:
	move $t4, $a1
Math_max_5:
	move $v0, $t4
Math_max_g_8:
	addi $sp, $fp, -8
Math_max_g_7:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_max_g_6:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_max_g_5:
	jr $ra
Math_min:
Math_min_g_16:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
Math_min_g_15:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
Math_min_g_14:
	addi $fp, $sp, 8
Math_min_g_13:
	addi $sp, $sp, 0
Math_min_10:
	move $t2, $a1
Math_min_9:
	move $t3, $a0
Math_min_8:
	slt $t5, $t3, $t2
Math_min_7:
	beqz $t5, Math_min_6
Math_min_4:
	move $t4, $a0
Math_min_3:
	move $v0, $t4
Math_min_g_4:
	addi $sp, $fp, -8
Math_min_g_3:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_min_g_2:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_min_g_1:
	jr $ra
Math_min_6:
	move $t4, $a1
Math_min_5:
	move $v0, $t4
Math_min_g_8:
	addi $sp, $fp, -8
Math_min_g_7:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_min_g_6:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_min_g_5:
	jr $ra
Math_pow:
Math_pow_g_37:
	sw $fp, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_36:
	sw $ra, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_35:
	addi $fp, $sp, 8
Math_pow_g_34:
	addi $sp, $sp, 0
Math_pow_20:
	move $t2, $a1
Math_pow_19:
	li $t3, 0
Math_pow_18:
	sle $t8, $t3, $t2
Math_pow_17:
	bnez $t8, Math_pow_16
	li $a0, 10
	li $v0, 11
	syscall
	syscall
	la $a0, exit_on_assert
	li $v0, 4
	syscall
	li $a0, 28
	li $v0, 1
	syscall
	li $v0, 10
	syscall
Math_pow_16:
	li $t8, 0
Math_pow_15:
	move $t4, $a1
Math_pow_14:
	seq $t8, $t4, $t8
Math_pow_13:
	beqz $t8, Math_pow_12
Math_pow_4:
	li $t2, 1
Math_pow_3:
	move $v0, $t2
Math_pow_g_33:
	addi $sp, $fp, -8
Math_pow_g_32:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_pow_g_31:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_pow_g_30:
	jr $ra
Math_pow_12:
	move $t6, $a0
Math_pow_11:
	li $t8, 1
Math_pow_10:
	move $t5, $a1
Math_pow_9:
	sub $t8, $t5, $t8
Math_pow_8:
Math_pow_g_21:
	sw $t2, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_20:
	sw $t8, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_19:
	sw $t3, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_18:
	sw $t4, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_17:
	sw $a3, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_16:
	sw $a2, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_15:
	sw $a1, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_14:
	sw $a0, 0($sp)
	subi $sp, $sp, 4
Math_pow_g_13:
	move $a1, $t8
Math_pow_g_12:
	move $a0, $t6
Math_pow_g_11:
	jal Math_pow
Math_pow_g_10:
	addi $sp, $sp, 0
Math_pow_g_9:
	addi $sp, $sp, 4
	lw $a0, 0($sp)
Math_pow_g_8:
	addi $sp, $sp, 4
	lw $a1, 0($sp)
Math_pow_g_7:
	addi $sp, $sp, 4
	lw $a2, 0($sp)
Math_pow_g_6:
	addi $sp, $sp, 4
	lw $a3, 0($sp)
Math_pow_g_5:
	addi $sp, $sp, 4
	lw $t4, 0($sp)
Math_pow_g_4:
	addi $sp, $sp, 4
	lw $t3, 0($sp)
Math_pow_g_3:
	addi $sp, $sp, 4
	lw $t8, 0($sp)
Math_pow_g_2:
	addi $sp, $sp, 4
	lw $t2, 0($sp)
Math_pow_g_1:
	move $t8, $v0
Math_pow_7:
	move $t7, $a0
Math_pow_6:
	mul $t2, $t7, $t8
Math_pow_5:
	move $v0, $t2
Math_pow_g_29:
	addi $sp, $fp, -8
Math_pow_g_28:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
Math_pow_g_27:
	addi $sp, $sp, 4
	lw $fp, 0($sp)
Math_pow_g_26:
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
x:
	.word 0
y:
	.word 0
descr_Math:
	.word 0
	.word Math_constructor
	.word Math_max
	.word Math_min
	.word Math_pow
exit_on_assert:
	.asciiz ">>> Échec d'assertion en ligne : "