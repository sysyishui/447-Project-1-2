.include "includes.asm"

.text
.globl main
main:

	jal	game

	li	v0, 10        # syscall exit
	syscall
