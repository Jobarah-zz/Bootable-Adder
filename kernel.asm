 org 0x7C00   ; add 0x7C00 to label addresses
 bits 16      ; tell the assembler we want 16 bit code
 
   mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; blank line?
   je mainloop       ; yes, ignore it
 
   mov si, buffer
   mov di, cmd_sum  ; "sum" command
   call strcmp
   jc .sum
 
   mov si,badcommand
   call print_string 
   jmp mainloop  
  
 .sum:
   call sum

   jmp mainloop
 
 badcommand db 'Bad command entered.', 0x0D, 0x0A, 0
 msg_firstNum db 'Insert first number:', 0x0D, 0x0A, 0
 msg_SecondNum db 'Insert second number:', 0x0D, 0x0A, 0
 prompt db '>', 0
 cmd_sum db 'sum', 0
 msg_help db 'My OS: Commands: sum', 0x0D, 0x0A, 0
 buffer times 64 db 0
 
 ; ================
 ; calls start here
 ; =============== 
 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
  .done:
   mov al, 0	; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10		; newline
 
   ret
 
 sum:
     mov si, msg_firstNum
     call print_string
    
     mov di, buffer
     call get_string

     mov bx, buffer
     call atoi

     mov dx, ax

     mov si, msg_SecondNum
     call print_string

     mov di, buffer
     call get_string

     mov bx, buffer
     call atoi

     add dx, ax

     mov ax, dx
     call print_int

     mov al, 0 ; null terminator
     stosb
    
     mov ah, 0x0E
     mov al, 0x0D
     int 0x10
     mov al, 0x0A
     int 0x10 
     ret

answer_buff times 16 db 0

atoi: ;receive en bx
   xor ax, ax ; zero a "result so far"
   .top:
      movzx cx, byte [bx] ; get a character
      inc bx ; ready for next one
      cmp cx, '0' ; valid?
      jb .done
      cmp cx, '9'
      ja .done
      sub cx, '0' ; "convert" character to number
      imul ax, 10 ; multiply "result so far" by ten
      add ax, cx ; add in current digit
      jmp .top ; until done

   .done:
      ret


print_int: ;void print_int(int number) value in ax 
    push    ax             
    push    cx             
    push    dx             
    push    si             
    mov     cx, 0          
 
divideLoop:
    inc     cx             
    mov     dx, 0          
    mov     si, 10         
    idiv    si             
    add     dx, 48         
    push    dx             
    cmp     ax, 0          
    jnz     divideLoop     

printLoop:
    dec     cx             
    mov     si, sp        
    call    print_string  
    pop     ax            
    cmp     cx, 0         
    jnz     printLoop     
 
    pop     si            
    pop     dx            
    pop     cx            
    pop     ax            
    ret

 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.
 
   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done: 	
   stc  ; equal, set the carry flag
   ret
 
   times 510-($-$$) db 0
   dw 0AA55h ; some BIOSes require this signature