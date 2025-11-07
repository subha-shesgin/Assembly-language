global _start

section .data
star: db '*'
nl:   db 10
prompt: db "Enter number of rows: ",0
plen: equ $-prompt

section .bss
inbuf: resb 64

section .text
_start:
    ; print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, plen
    syscall

    ; read input
    mov rax, 0
    mov rdi, 0
    mov rsi, inbuf
    mov rdx, 64
    syscall

    ; parse digits
    xor rax, rax
    mov rsi, inbuf

.parse_loop:
    mov bl, [rsi]
    cmp bl,'0'
    jl .parsed
    cmp bl,'9'
    jg .parsed
    imul rax, rax, 10
    sub bl,'0'
    movzx rbx, bl
    add rax, rbx
    inc rsi
    jmp .parse_loop

.parsed:
    mov r8, rax        ; N safely
    mov r9, 1          ; outer loop counter i = 1

.outer_loop:
    cmp r9, r8
    jg .exit

    mov rbx, r9        ; inner loop counter j = i
.inner_loop:
    cmp rbx, 0
    je .newline

    mov rax, 1
    mov rdi, 1
    mov rsi, star
    mov rdx, 1
    syscall

    dec rbx
    jmp .inner_loop

.newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    inc r9
    jmp .outer_loop

.exit:
    mov rax, 60
    xor rdi, rdi
    syscall

