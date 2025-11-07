; compare_numbers.asm
; Takes two integers (positive or negative) as input,
; compares them, and prints which one is greater or if they are equal.

section .bss
    num1    resb 16
    num2    resb 16

section .data
    msg1 db "Enter first number: ",0
    len_msg1 equ $-msg1

    msg2 db "Enter second number: ",0
    len_msg2 equ $-msg2

    greater db "First number is greater",10,0
    len_greater equ $-greater

    smaller db "Second number is greater",10,0
    len_smaller equ $-smaller

    equal db "Both numbers are equal",10,0
    len_equal equ $-equal

section .text
    global _start

_start:
    ; --- Ask for first number ---
    mov rax, 1          ; sys_write
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len_msg1
    syscall

    ; --- Read first number ---
    mov rax, 0          ; sys_read
    mov rdi, 0
    mov rsi, num1
    mov rdx, 16
    syscall

    ; --- Convert to integer ---
    mov rsi, num1
    call str_to_int
    mov rbx, rax        ; store first number in rbx

    ; --- Ask for second number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len_msg2
    syscall

    ; --- Read second number ---
    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 16
    syscall

    ; --- Convert to integer ---
    mov rsi, num2
    call str_to_int
    mov rcx, rax        ; store second number in rcx

    ; --- Compare ---
    cmp rbx, rcx
    jg first_greater
    jl second_greater

equal_case:
    mov rax, 1
    mov rdi, 1
    mov rsi, equal
    mov rdx, len_equal
    syscall
    jmp end_prog

first_greater:
    mov rax, 1
    mov rdi, 1
    mov rsi, greater
    mov rdx, len_greater
    syscall
    jmp end_prog

second_greater:
    mov rax, 1
    mov rdi, 1
    mov rsi, smaller
    mov rdx, len_smaller
    syscall

end_prog:
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; ----------------------------------------
; str_to_int: converts string in RSI to integer in RAX
; Handles optional leading '-'
; Stops at newline or null terminator
str_to_int:
    xor rax, rax        ; result = 0
    xor rcx, rcx
    mov r8, 1           ; sign = +1

    ; Check for leading minus sign
    mov al, byte [rsi]
    cmp al, '-'
    jne .parse_digits
    mov r8, -1
    inc rsi

.parse_digits:
    xor rax, rax        ; clear result
.next_char:
    mov cl, byte [rsi]
    cmp cl, 10          ; newline?
    je .done
    cmp cl, 0
    je .done
    sub cl, '0'
    cmp cl, 9
    ja .done            ; non-digit, stop
    imul rax, rax, 10
    movzx rcx, cl       ; zero-extend digit
    add rax, rcx
    inc rsi
    jmp .next_char

.done:
    ; Apply sign
    cmp r8, 1
    je .ret
    neg rax
.ret:
    ret

