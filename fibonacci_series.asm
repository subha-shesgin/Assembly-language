; fibonacci.asm
; Build: nasm -f elf64 fibonacci.asm -o fibonacci.o
; Link : ld fibonacci.o -o fibonacci
; Run  : ./fibonacci

section .bss
    inbuf   resb 32

section .data
    prompt  db "Enter number of terms: ",0
    lenp    equ $-prompt
    space   db " ",0
    newline db 10

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
    jb .done
    cmp al, '9'
    ja .done
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse
.done:

    ; ---- Edge case: if n == 0, exit ----
    test r12, r12
    jz exit

    ; ---- Fibonacci variables ----
    xor r13, r13         ; f0 = 0
    mov r14, 1           ; f1 = 1
    xor r15, r15         ; counter = 0

fib_loop:
    cmp r15, r12
    jge exit             ; printed n terms, exit

    ; ---- print f0 ----
    mov rdi, r13
    call print_num

    ; print space
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

    ; ---- next Fibonacci ----
    mov rax, r13
    add rax, r14
    mov r13, r14         ; f0 = f1
    mov r14, rax         ; f1 = next

    inc r15
    jmp fib_loop

; ---- Print number in rdi as decimal ----
print_num:
    mov rax, rdi
    mov rcx, 10
    mov rbx, rsp
    sub rsp, 32
    mov rsi, rsp
    add rsi, 32

.convert:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .convert

    mov rax, 1
    mov rdi, 1
    mov rdx, rsp
    add rdx, 32
    sub rdx, rsi
    mov rsi, rsi
    syscall

    mov rsp, rbx
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
