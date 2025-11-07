; lcm.asm - Compute LCM of two numbers using GCD
; NASM 64-bit Linux

section .bss
    num1 resb 20
    num2 resb 20
    result resb 20

section .data
    prompt1 db "Enter first number: ",0
    prompt1_len equ $-prompt1
    prompt2 db "Enter second number: ",0
    prompt2_len equ $-prompt2
    newline db 10,0

section .text
    global _start

_start:
    ; --- Read first number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num1
    mov rdx, 20
    syscall

    mov rsi, num1
    call str2int
    mov rbx, r8           ; store first number

    ; --- Read second number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 20
    syscall

    mov rsi, num2
    call str2int
    mov rcx, r8           ; second number

    ; --- Compute GCD ---
    mov r9, rbx           ; keep copy of first number
    mov r10, rcx          ; keep copy of second number
gcd_loop:
    cmp rcx, 0
    je gcd_done
    mov rax, rbx
    xor rdx, rdx
    div rcx
    mov rbx, rcx
    mov rcx, rdx
    jmp gcd_loop
gcd_done:
    mov r8, rbx           ; GCD in r8

    ; --- Compute LCM = (a * b) / GCD ---
    mov rax, r9           ; rax = first number
    mov rbx, r10          ; rbx = second number
    mul rbx               ; rdx:rax = rax * rbx
    mov rbx, r8           ; GCD
    xor rdx, rdx          ; clear rdx for division
    div rbx               ; rax = LCM
    mov r8, rax           ; store LCM in r8

    ; --- Convert LCM to string ---
    mov rdi, result
    call int2str

    ; --- Print LCM ---
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 20
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall

; -----------------------------
; Convert string to integer (r8)
; Input: rsi = pointer to string
; Output: r8 = integer
str2int:
    xor r8, r8
.next_digit:
    mov al, byte [rsi]
    cmp al, 10
    je .done
    sub al, '0'
    imul r8, r8, 10
    add r8, rax
    inc rsi
    jmp .next_digit
.done:
    ret

; -----------------------------
; Convert integer in r8 to string at rdi
int2str:
    mov rax, r8
    mov rcx, 0
    mov rbx, 10
.reverse_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    cmp rax, 0
    jne .reverse_loop

.print_loop:
    pop rax
    mov [rdi], al
    inc rdi
    dec rcx
    cmp rcx, 0
    jne .print_loop
    mov byte [rdi], 0
    ret
