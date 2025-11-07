; gcd_final_fixed.asm
; NASM 64-bit Linux
; Reads two numbers from user, strips newline, computes GCD, prints result

global _start

section .data
prompt1 db "Enter first number: ",0
plen1   equ $-prompt1
prompt2 db "Enter second number: ",0
plen2   equ $-prompt2
msg     db "GCD is: ",0
msg_len equ $-msg
nl      db 10

section .bss
buf1 resb 32
buf2 resb 32

section .text
_start:
    ; --- Prompt first number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt1
    mov rdx, plen1
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, buf1
    mov rdx, 32
    syscall
    mov rsi, buf1
    call strip_newline
    call atoi
    mov r8, rax       ; store first number

    ; --- Prompt second number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, plen2
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, buf2
    mov rdx, 32
    syscall
    mov rsi, buf2
    call strip_newline
    call atoi
    mov r9, rax       ; store second number

    ; --- Euclidean GCD ---
    mov rax, r8       ; a
    mov rbx, r9       ; b

gcd_loop:
    cmp rbx, 0
    je gcd_done
    xor rdx, rdx       ; zero RDX BEFORE div
    div rbx
    mov rax, rbx
    mov rbx, rdx
    jmp gcd_loop

gcd_done:
    mov r10, rax       ; save GCD safely

    ; --- Print "GCD is: " ---
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall

    ; --- Convert GCD to string ---
    mov rax, r10       ; use saved GCD
    mov rbx, 10
    lea rsi, [rsp-20]
    mov rcx, 0

convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz convert_loop

    ; --- Print GCD string ---
    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

    ; --- Print newline ---
    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    ; --- Exit ---
    mov rax, 60
    xor rdi, rdi
    syscall

; --- atoi function ---
; Converts string in RSI to integer in RAX
atoi:
    xor rax, rax
.next_digit:
    mov bl, [rsi]
    cmp bl,'0'
    jl .done
    cmp bl,'9'
    jg .done
    imul rax, rax, 10
    sub bl,'0'
    movzx rbx, bl
    add rax, rbx
    inc rsi
    jmp .next_digit
.done:
    ret

; --- strip_newline function ---
; Replaces first newline (ASCII 10) with null terminator
strip_newline:
    mov rbx, rsi
.strip_loop:
    cmp byte [rbx], 0
    je .strip_done
    cmp byte [rbx], 10
    jne .next_char
    mov byte [rbx], 0
    jmp .strip_done
.next_char:
    inc rbx
    jmp .strip_loop
.strip_done:
    ret

