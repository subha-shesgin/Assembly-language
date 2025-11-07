; fibo64.asm
; Build: nasm -f elf64 fibo64.asm -o fibo64.o
; Link : ld fibo64.o -o fibo64
; Run  : ./fibo64

section .bss
    inbuf   resb 32

section .data
    prompt  db "Enter a number: ",0
    lenp    equ $-prompt
    msgfib  db "Fibonacci",10,0
    lenfib  equ $-msgfib
    msgnot  db "Not Fibonacci",10,0
    lennot  equ $-msgnot

section .text
    global _start

_start:
    ; ---- Prompt ----
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, lenp
    syscall

    ; ---- Read input ----
    mov rax, 0
    mov rdi, 0
    mov rsi, inbuf
    mov rdx, 32
    syscall

    ; ---- Parse ASCII -> integer in r12 ----
    mov rsi, inbuf
    xor r12, r12
.parse:
    mov al, [rsi]
    cmp al, '0'
    jb  .done
    cmp al, '9'
    ja  .done
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse
.done:

    ; ---- Edge case: if n < 0, Not Fibonacci ----
    cmp r12, 0
    jl  print_not
    cmp r12, 0
    je  print_fib        ; 0 is Fibonacci

    ; ---- Fibonacci loop ----
    xor r13, r13         ; f0 = 0
    mov r14, 1           ; f1 = 1

fib_loop:
    cmp r13, r12
    je  print_fib        ; n matches Fibonacci
    cmp r13, r12
    ja  print_not        ; n exceeded Fibonacci

    ; next = f0 + f1
    mov rax, r13
    add rax, r14
    mov r13, r14         ; f0 = f1
    mov r14, rax         ; f1 = next
    jmp fib_loop

; ---- Print Fibonacci ----
print_fib:
    mov rax, 1
    mov rdi, 1
    mov rsi, msgfib
    mov rdx, lenfib
    syscall
    jmp exit

; ---- Print Not Fibonacci ----
print_not:
    mov rax, 1
    mov rdi, 1
    mov rsi, msgnot
    mov rdx, lennot
    syscall

; ---- Exit ----
exit:
    mov rax, 60
    xor rdi, rdi
    syscall
