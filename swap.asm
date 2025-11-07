section .data
    msg1 db "Enter first number: ",0
    msg1_len equ $-msg1
    msg2 db "Enter second number: ",0
    msg2_len equ $-msg2
    outmsg db "After swapping: ",0
    outmsg_len equ $-outmsg
    newline db 10

section .bss
    inbuf1  resb 10       ; buffer for first number
    inbuf2  resb 10       ; buffer for second number
    num1    resq 1        ; store first number (8 bytes)
    num2    resq 1        ; store second number (8 bytes)
    numbuf  resb 20       ; buffer for printing numbers

section .text
global _start

_start:
    ; -------- Print "Enter first number:" --------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, msg1_len
    syscall

    ; -------- Read first number --------
    mov rax, 0
    mov rdi, 0
    mov rsi, inbuf1
    mov rdx, 10
    syscall

    ; -------- Convert first number string to integer --------
    xor r12, r12        ; r12 = num1
    mov rsi, inbuf1
.parse1:
    mov al, [rsi]
    cmp al, '0'
    jb .done1
    cmp al, '9'
    ja .done1
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse1
.done1:
    mov [num1], r12

    ; -------- Print "Enter second number:" --------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, msg2_len
    syscall

    ; -------- Read second number --------
    mov rax, 0
    mov rdi, 0
    mov rsi, inbuf2
    mov rdx, 10
    syscall

    ; -------- Convert second number string to integer --------
    xor r12, r12        ; r12 = num2
    mov rsi, inbuf2
.parse2:
    mov al, [rsi]
    cmp al, '0'
    jb .done2
    cmp al, '9'
    ja .done2
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse2
.done2:
    mov [num2], r12

    ; -------- Swap numbers --------
    mov rax, [num1]
    mov rbx, [num2]
    mov [num1], rbx
    mov [num2], rax

    ; -------- Print output message --------
    mov rax, 1
    mov rdi, 1
    mov rsi, outmsg
    mov rdx, outmsg_len
    syscall

    ; -------- Print num1 --------
    mov rax, [num1]
    mov rsi, numbuf
    call int_to_string
    mov rax, 1
    mov rdi, 1
    mov rdx, r13          ; r13 = length of string returned
    syscall

    ; -------- Print space --------
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; -------- Print num2 --------
    mov rax, [num2]
    mov rsi, numbuf
    call int_to_string
    mov rax, 1
    mov rdi, 1
    mov rdx, r13
    syscall

    ; -------- Print newline --------
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; -------- Exit --------
    mov rax, 60
    xor rdi, rdi
    syscall

; -------- Function: int_to_string --------
; Converts rax integer into decimal string stored at rsi
; Returns length in r13
int_to_string:
    mov rbx, 10          ; divisor
    xor r12, r12          ; digit counter
    lea rdi, [rsi+19]     ; point to end of buffer
    mov byte [rdi], 0     ; null terminator
.convert_loop:
    xor rdx, rdx
    div rbx               ; rax / 10, quotient in rax, remainder in rdx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc r12
    cmp rax, 0
    jne .convert_loop
    mov r13, r12          ; length of string
    mov rsi, rdi          ; pointer to start of string
    ret

