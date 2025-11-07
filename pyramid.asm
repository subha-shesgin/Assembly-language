
; pyramid64.asm
; Build: nasm -f elf64 pyramid64.asm -o pyramid64.o
; Link : ld pyramid64.o -o pyramid64
; Run  : ./pyramid64

section .bss
    inbuf   resb 32  ; reserve 32 bytes of memory in buffer not in executable file 

section .data       ; the initialized data section. Anything you define here gets stored in the executable
    prompt  db "Enter number: "
    prompt_len equ $-prompt
    star    db "*"
    space   db " "
    newline db 10

section .text
    global _start

_start:
    ; write prompt
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; read input
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, inbuf
    mov rdx, 32
    syscall                 ; rax = bytes read (unused here)

    ; parse unsigned integer from ASCII in inbuf -> r12
    xor r12, r12            ; r12 = total rows
    mov rsi, inbuf
.parse:
    mov al, [rsi]
    cmp al, '0' ; compae with 0
    jb  parsed
    cmp al, '9'
    ja  parsed
    imul r12, r12, 10
    movzx rdx, al
    sub rdx, '0'
    add r12, rdx
    inc rsi
    jmp .parse

parsed:
    ; if rows == 0, just exit
    test r12, r12
    jz exit

    mov r13, 1              ; current row = 1
row_loop:
    cmp r13, r12
    jg  exit

    ; spaces = r12 - r13
    mov rbx, r12
    sub rbx, r13
    call print_spaces

    ; stars = 2*r13 - 1
    mov rbx, r13
    shl rbx, 1
    sub rbx, 1
    call print_stars

    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    inc r13
    jmp row_loop

; rbx = count; prints that many spaces
print_spaces:
    test rbx, rbx
    jle .ps_done
.ps_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall
    dec rbx
    jg  .ps_loop
.ps_done:
    ret

; rbx = count; prints that many stars
print_stars:
    test rbx, rbx
    jle .pt_done
.pt_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, star
    mov rdx, 1
    syscall
    dec rbx
    jg  .pt_loop
.pt_done:
    ret

exit:
    mov rax, 60             ; sys_exit
    xor rdi, rdi
    syscall
