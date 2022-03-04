title drisnya.asm
.model small
.stack 0100h

.data

debugMessage	db "Awaiting input: $"
sample		db "13 $"

initRow		db 00h
initColumn	db 00h							
extraCounter	dw 00h

inputBuffer label byte

bufferCapacity	db 64
bufferVolume	db 0
inbuffer	db 255 dup('$')

outputBuffer label byte

outbuffer	db 255 dup ('$')
linefeed	db 0Ah, '$'

digitCodes	db '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'

.code

Start:	mov ax, @data	 ;Moving the address of data segment to ax
	mov ds, ax   	 ;here it goes for real

	mov bh, 4Ch
	call clear

	lea bx, debugMessage
	call print

	lea bx, sample
	call measure		;calculating length of debugMessage

	lea ax, sample
	lea cx, inbuffer
	call load		

	call getint
	call line
	
	mov cx, dx
	mov al, 0bh
	mov bl, 96h
	mov dh, 36
	mov dl, 12

	call drawh

	call exit

; EXIT
; kills the program.

exit:	mov ax, 4C00h
	int 21h
	ret	

; READ
;
; fills the inputBuffer with up to 255 symbols

read:	push ax
	push dx

	mov ah, 0Ah
	lea dx, inputBuffer
	int 21h

	pop dx
	pop ax

	ret

; WRITE
;
; prints up to 255 symbols stored in outputBuffer

write:	push ax
	push dx
	
	mov ah, 09h
	lea dx, outputBuffer
	int 21h

	pop dx
	pop ax
	ret

; PRINT
;
;

print:	push ax
	push cx
	push dx

	call measure

	mov ax, bx
	lea cx, outputBuffer
	call load
	
	call write

	pop dx
	pop cx
	pop ax

	ret
	

; LINE
;
; jump to next line.
	
line:	push ax
	push dx
	
	lea dx, linefeed
	mov ah, 09h
	int 21h

	pop dx
	pop ax
	
	ret

; LOAD
;
; loads dl bytes from ax to cx
; DESTROYS EVERYTHING

load:	push bx
	push dx

	loadNext:	cmp dl, 0
			jle loadReady
			
			mov bx, ax
			mov dh, [bx]
			mov bx, cx
			mov [bx], dh

			inc ax
			inc cx
			dec dl
			jmp loadNext

	loadReady:	pop dx
			pop bx
			ret

; MEASURE
;
; loads length of the string beginning from bx to dl

measure: 
	push cx

	mov dl, 0	 
	nextChar:	mov ch, [bx]
	
			cmp ch, 0
			je measureRdy
			cmp ch, '$'
			je measureRdy
			
			inc bx
			inc dl

			jmp nextChar
		
	measureRdy:	pop cx
			inc dl
			ret

; GETINT
;
; scans for int in input buffer. moves it to DX

getint:	push ax
	push bx
	push cx

	lea bx, inbuffer
	mov dx, 0

	nextDigit:	mov cl, 0
			mov ch, [bx]

			push bx
			lea bx, digitCodes

			checkForDigit:	cmp ch, [bx]
					je isDigit

					cmp cl, 9
					je intRdy
					
					inc ax
					inc cl
					
					jmp checkForDigit
	isDigit:	push ax
			
			mov bx, 10
			mul bx

			pop ax
			pop bx

			mov ch, 0
			add dx, cx

			inc bx
			jmp nextDigit	
	
	intRdy:	pop cx
		pop bx
		pop ax

		ret

; INTSTR
;
; converts an int to string


						
; CLEAR
; clears the screen.
;
; BH - attribute
	
clear:	push ax
	push cx
	push dx

	mov ax, 0600h
	mov cx, 0000h
	mov dx, 184Fh
	int 10h

	pop dx
	pop cx
	pop ax

	ret

; POINT
; sets the cursor to a designated position.
;
; DH - target line
; DL - target column

point:	push ax
	push bx
	
	mov ah, 02h
	mov bh, 00h
	int 10h

	pop bx
	pop ax

	ret

; DRAW
; puts a character to a designated position.
;
; AL - char code
; BL - attribute
; DH - target line
; DL - target column
;


;	GRAPHIC FUNCTIONS
; -----------------------------


draw:	call point

	push ax
	push bx
	push cx

	mov ah, 09h
	mov bh, 0
	mov cx, 1
	int 10h

	pop cx
	pop bx
	pop ax

	ret

; DRAWH
; draws a horizontal line.
;
; AL - char code
; BL - attribute
; CX - length
; DH - target line
; DL - target column

drawh:	call point
	
	push ax
	push bx

	mov ah, 09h
	mov bh, 0
	int 10h

	pop bx
	pop ax

	ret	

; DRAWV
; draws a vertical line.
;
; AL - char code
; BL - attribute
; CX - length
; DH - target line (upper end)
; DL - target column
;
; MOVES THE CURSOR BELOW DRAWN LINE

drawv:	mov extraCounter, cx
	
	drawvLoop: mov cx, extraCounter

		   cmp cx, 0     ;comparing cx and 0 which toggles a flag

		   jbe drawvExit ;quit the cycle if counter is 0 or lower

		   dec cx
		   mov extraCounter, cx
		
		   call draw
		   inc dh        ;go one unit lower
		   jmp drawvLoop

	drawvExit: ret

end Start																																												