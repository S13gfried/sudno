title drisnya.asm
.model small
.stack 0100h

.data

initRow db 00h
extraCounter dw 00h

.code

Start:	mov ax, @data	 ;Moving the address of data segment to ax
	mov ds, ax   	 ;here it goes for real

	mov bh, 0Eh
	call clear

	mov dh, 10
	mov dl, 20
	call molchatdoma

	call exit

; CLEAR
; clears the screen.
;
; BH - attribute
; DESTROYS AX, CX, DX
	
clear:	mov ax, 0600h
	mov cx, 0000h
	mov dx, 184Fh
	int 10h

	ret

; POINT
; sets the cursor to a designated position.
;
; DH - target line
; DL - target column
;
; DESTROYS AH, BH

point:	mov ah, 02h
	mov bh, 00h
	int 10h
	ret

; DRAW
; puts a character to a designated position.
;
; AL - char code
; BL - attribute
; DH - target line
; DL - target column
;
; DESTROYS AH, BH, CX

draw:	call point

	mov ah, 09h
	mov bh, 0
	mov cx, 1
	int 10h

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
	
	mov ah, 09h
	mov bh, 0
	int 10h

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

; MOLCHATDOMA
; renders BUERAKUS in a specified location.
;
; DH - top left line
; DL - top left column
;
; DESTROYS EVERYTHING ELSE

molchatdoma:
	mov initRow, dh

	mov bl, 60h
	mov al, 00h

	; 0,1 ---------

	add dh, 5
	call draw

	sub dh, 4
	inc dl
	call draw

	inc dh
	mov al, 81h
	call draw

	mov al, 00h
	inc dh
	mov cx, 3
	call drawv
	
	; 2 ------------

	mov dh, initRow
	inc dl
	call draw

	inc dh
	mov al, 177
	mov bl, 67h
	call draw

	inc dh
	mov al, 93h
	mov bl, 60h
	call draw

	mov al, 00h
	inc dh
	mov cx, 3
	call drawv

	; 3 ------------

	mov dh, initRow
	inc dl
	call draw

	inc dh
	mov bl, 78h
	call draw

	mov bl, 60h
	mov al, 85h
	inc dh
	call draw
	
	mov al, 00h
	inc dh
	call draw
	
	; 4 -------------

	mov dh, initRow
	inc dl
	call draw
	
	inc dh
	mov bl, 78h
	call draw

	mov bl, 60h
	mov al, 90h
	inc dh
	call draw

	mov al, 00h
	inc dh
	call draw

	add dh, 2
	call draw

	; 5 --------------

	mov dh, initRow
	inc dl
	call draw

	inc dh
	mov al, 177
	mov bl, 67h
	call draw
	
	inc dh
	mov al, 80h
	mov bl, 60h
	call draw

	mov al, 00h
	inc dh
	mov cx, 3
	call drawv

	; 6 ---------------

	mov dh, initRow
	inc dl
	inc dh
	call draw

	inc dh
	mov al, 8ah
	call draw

	inc dh
	mov al, 00h
	mov cx, 3
	call drawv

	ret

; EXIT
; kills the program.

exit:	mov ax, 4C00h
	int 21h
	ret

end Start																																													
