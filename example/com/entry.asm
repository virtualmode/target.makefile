; Assembler example.

.286						; CPU type.

.model TINY					; Memory of model.
	extrn _main:near		; Prototype of C func.

.code
	org 07c00h				; For boot sector.

main:
	jmp short start			; Go to main.
	nop

start:
	cli
	mov ax, cs				; Setup segment registers.
	mov ds, ax				; Make DS correct.
	mov es, ax				; Make ES correct.
	mov ss, ax				; Make SS correct.
	mov bp, 7c00h
	mov sp, 7c00h			; Setup a stack.
	sti

	call _main				; Start the program.
	ret

	END main				; End of program.
