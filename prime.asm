section .data
    msg db "Enter a number: ",0
    msg_len equ $-msg
    prime_msg db "Number is prime",0
    prime_msg_len equ $-prime_msg
    not_prime_msg db "Number is not prime",0
    not_prime_msg_len equ $-not_prime_msg
    newline db 10

section .bss
    inbuf resb 10      ; buffer for input
    num   resq 1       ; number to check

section .text
global _start

_start:
    ; -------- Print prompt --------
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; -------- Read input --------
    mov rax, 0
    mov rdi, 0
    mov rsi, inbuf
    mov rdx, 10
    syscall

    ; -------- Convert string to integer --------
    xor r12, r12       ; r12 = number
    mov rsi, inbuf
.parse:
    mov al, [rsi]
    cmp al, '0'
    jb .done_parse
    cmp al, '9'
    ja .done_parse
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse
.done_parse:
    mov [num], r12     ; store number

    ; -------- Prime check --------
    mov rax, [num]      ; rax = number to check
    cmp rax, 2
    jb .not_prime       ; numbers less than 2 are not prime
    je .prime           ; 2 is prime

    mov rbx, 2          ; divisor = 2
.check_loop:
    mov rdx, 0
    mov rcx, rax
    div rbx              ; rax / rbx, quotient in rax, remainder in rdx
    cmp rdx, 0
    je .not_prime         ; divisible → not prime
    inc rbx
    mov rax, [num]
    cmp rbx, rax
    jl .check_loop

.prime:
    ; print prime_msg
    mov rax, 1
    mov rdi, 1
    mov rsi, prime_msg
    mov rdx, prime_msg_len
    syscall
    jmp .done

.not_prime:
    ; print not_prime_msg
    mov rax, 1
    mov rdi, 1
    mov rsi, not_prime_msg
    mov rdx, not_prime_msg_len
    syscall

.done:
    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; -------- Exit --------
    mov rax, 60
    xor rdi, rdi
    syscall

