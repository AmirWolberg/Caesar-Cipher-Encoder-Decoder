IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------

msgpass db 'Enter password to encrypt the given message(up to 254 chars )$'
get_msgpass db 257 dup (?)

decmsg db 'Enter the message you wish to decrypt (up to 254 chars)$'
get_decmsg db 257 dup (?)

line db 'I-----------------------------------------------------------------------I$'

msgmsg db 'Enter message to encrypt(up to 254 chars)$'
get_msgencrypt db 257 dup (?)

passconfirm db 'Enter password to decrypt message$'
confirmpass db 257 dup (?)

stars db '********************************************************$'

open db 'Enter 1 to Encrypt and Any other charecter to Decrypt message with unknown password$'

tryagain db 'Do you wish to try again?(Enter 1 for yes and any other charecter for no)$'

wrongdec db 'Not satisfied with the decryption? Get all 26 possible options and choose the logical one by pressing 1 , to finish press any other charecter$'

letter_counter db 26 dup (0)

CODESEG

; printing stuffz and/or getting input <====================================================


; print the char and than print space , mov to dl and call this proc
proc printchar_space
	mov ah,2
	int 21h
	
	mov dl, ' '
	mov ah,2
	int 21h
	
	ret
endp


proc tryagainproc
	push bp
	mov bp,sp
	mov dx,offset tryagain
	mov ah,9h
	int 21h
	pop bp
	ret
endp


proc baddec
	push bp
	mov bp,sp
	mov dx,offset wrongdec
	mov ah,9h
	int 21h
	pop bp
	ret
endp


proc openmsg
	push bp
	mov bp,sp
	mov dx,offset open
	mov ah,9h
	int 21h
	pop bp
	ret
endp


proc printstar
push bp
mov bp,sp
mov dx,offset stars
mov ah,9h
int 21h
call print_newline
pop bp
ret
endp


;gets the message to be encrypted and asks for it
proc message
push bp
mov bp,sp
mov dx,offset msgmsg
mov ah,9h
int 21h
call print_newline

mov dx,offset get_msgencrypt
mov bx,dx
mov [byte ptr bx], 255
mov ah,0Ah
int 21h
pop bp
ret
endp


proc decmessage
push bp
mov bp,sp
mov dx,offset decmsg
mov ah,9h
int 21h
call print_newline

mov dx,offset get_decmsg
mov bx,dx
mov [byte ptr bx], 255
mov ah,0Ah
int 21h
pop bp
ret
endp


;gets a string
;TODO: seperate this function into 2 parts (input + ourput)
proc decryptpass 
	push bp
	mov bp,sp
	call print_newline
	call printline
	call print_newline
	mov dx,offset passconfirm
	mov ah,9h
	int 21h
	call print_newline

	mov dx,offset confirmpass
	mov bx,dx
	mov [byte ptr bx], 255
	mov ah,0Ah
	int 21h
	pop bp
	ret
endp


proc printline
push bp
mov bp,sp
mov dx,offset line
mov ah,9h
int 21h
call print_newline
pop bp
ret
endp


; recieves the password and asks for it 
proc password
push bp
mov bp,sp
mov dx,offset msgpass
mov ah,9h
int 21h
call print_newline

mov dx,offset get_msgpass
mov bx,dx
mov [byte ptr bx], 255
mov ah,0Ah
int 21h
pop bp
ret
endp


;printchar gets a characer in dl and prints the character
proc printchar
	mov ah,2
	int 21h
	ret
endp

	
proc print_newline
	mov dl, 10
	call printchar
	mov dl, 13
	call printchar
	ret
endp


; gets a char in ah
proc get_char
	mov ah , 1
	int 21h
	ret
endp




;--------------------------------------------------------------------------------------------------------------------------------------------




;Gets a 3 letter string
;computes a number according to the letters
;returns the number in ax
proc convert_key_to_number
	lea bx, [get_msgpass]
	inc bx ;bx points to the length of the string
	mov cx, [bx]
	xor ch, ch
	xor ax , ax
	loop_start:
	inc bx
	add al, [byte ptr bx]
	adc ah, 0 ; add the carry 
	loop loop_start
	
	;ax has the number of the code
	axdec:
	cmp ax , 26 
	jb endofthis
	sub ax , 26
	jmp axdec
	endofthis:
ret
endp



;stuff related to encrypting
proc encrypting
	call convert_key_to_number
	xor cx , cx
	lea si , [get_msgencrypt]
	inc si
	mov cx , [si]
	inc si
	xor ch, ch
	passwordloop:
	add [si] , ax
	add si , 1
	loop passwordloop

	xor cx , cx
	xor dx , dx
	lea si , [get_msgencrypt]
	inc si
	mov cx , [si]
	inc si
	xor ch, ch
	encloop:
	mov dl , [si]
	call printchar
	add si , 1
	loop encloop
	ret
endp



;compares the encrypting key and the decrypting key



proc Decryptingwithpass
	call decryptpass
	
	;Begin compare confirmpass to get_msgpass
	xor cx, cx
	xor dx, dx
	xor bx, bx
	lea di, [confirmpass]
	inc di
	mov cl , [byte ptr di] ;TODO: ask teacher
	inc di
	lea si , [get_msgpass]
	inc si
	inc si
	decryptloop:
	mov dl , [byte ptr di]
	mov bl , [byte ptr si]
	cmp dl , bl
	jne wrongpass
	add di , 1
	add si , 1
	loop decryptloop
	; End compare confirmpass to get_msgpass
	
    call print_newline
	call convert_key_to_number

	; Begin convert decrypted message
	xor cx , cx
	lea si , [get_msgencrypt]
	inc si
	mov cl , [byte ptr si]
	inc si
	passwloop:
	sub [si] , ax
	add si , 1
	loop passwloop
	; end convert decrypted message

	xor cx , cx
	xor dx , dx
	lea si , [get_msgencrypt]
	inc si
	mov cl , [byte ptr si]
	inc si
	decloop:
	mov dl , [si]
	call printchar
	add si , 1
	loop decloop

	wrongpass:
	ret
endp




proc input
call printline
call print_newline
call message 
call print_newline
call password
call print_newline
call print_newline
call printline
ret
endp




;----------------------------------------------------------------------------------------------------------------------------------------------------




proc openscreen
	reset:
	call print_newline
	call printstar
	call printstar
	call printstar
	call printstar
	call printstar
	call print_newline
	call print_newline
	call openmsg
	call print_newline
	call print_newline
	call printstar
	call printstar
	call printstar
	call printstar
	call printstar
	call print_newline
	call get_char
	cmp al , '1'
	call print_newline
	jne NopassDecrypt
	encrypt:
	call input
	call convert_key_to_number
	call encrypting
	call decryptingwithpass
	call print_newline
	jmp reset
	NopassDecrypt:
	call decmessage
	call print_newline
    call searche
	jmp reset
	ret
endp




;--------------------------------------------------------------------------------------------------------------------------------------------




;CHECK always if the letter that is present most times is e , if yes print it , if no keep decreasing if you hit 0 reset and do it manually 
proc decrypting 
call print_newline
mov ax , 1
checkloop:
call print_newline
inc bx
xor cx , cx
lea si , [get_decmsg]
inc si
mov cl, [byte ptr si]
inc si
passwloop1:
sub [si] , ax
inc si 
loop passwloop1

xor cx , cx
xor dx , dx
lea si , [get_decmsg]
inc si
mov cl , [byte ptr si]
inc si
dec1loop:
mov dl , [si]
call printchar
add si , 1
loop dec1loop

call tryagainproc
call get_char
cmp al , '1'
je checkloop




ret
endp




proc searche
	; TODO: Put the below code in proc
	; Begin fill letter_counter
	xor cx , cx
	lea si , [get_decmsg]
	lea di , [letter_counter]
	inc si
	mov cl , [byte ptr si]
	inc si
	counterloop:
	xor bx, bx
	mov bl, [byte ptr si]
	sub bl, 'a'
	add bx, di
	inc [byte ptr bx]
	inc si 
	loop counterloop
	; End fill letter_counter

	; Begin find biggest number in letter_counter
	mov cx , 26 
	lea di , [letter_counter]
	xor ax , ax ; hold the biggest number
	xor bx , bx ; hold the address of the biggest number
	find_biggest_num:
	cmp al, [byte ptr di]
	ja endbig
	mov al , [byte ptr di]
	mov bx , di 
	endbig: 
	inc di 
	loop find_biggest_num
	; End find biggest number in letter_counter
	lea di , [letter_counter]
    sub bx , di
	add bx , 'a'
	sub bx , 'e'
	;bx contains the value you need to subtract from the letters of the message
	; End find biggest number in letter_counter
	
	xor cx , cx
	lea si , [get_decmsg]
	inc si
	mov cl , [byte ptr si]
	inc si
	eloop:
	sub [si] , bx
	add si , 1
	loop eloop
	; end convert decrypted message

	xor cx , cx
	xor dx , dx
	lea si , [get_decmsg]
	inc si
	mov cl , [byte ptr si]
	inc si
	printeloop:
	mov dl , [si]
	call printchar
	add si , 1
	loop printeloop
	
	; end of check by using the most used letter and treating it as e 
	
	; begin checking all 26 options 
	
    ;Get all 26 possible decryptions incase its a short message and/or this option failed
	call print_newline
	call baddec
	call print_newline
	call get_char
	cmp al , '1'
	jne endofdecryption
	;getting decmsg back to its original values 
	xor cx , cx
	lea si , [get_decmsg]
	inc si
	mov cl , [byte ptr si]
	inc si
	e_reverse_loop:
	add [si] , bx
	add si , 1
	loop e_reverse_loop
	call decrypting
	endofdecryption:
	ret
endp




start:
	mov ax, @data
	mov ds, ax
	
	
; --------------------------
; Your code here
; 
call openscreen


exit:
	mov ax, 4c00h
	int 21h
END start
