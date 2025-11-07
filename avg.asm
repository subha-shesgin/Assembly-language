; NASM x86-64 Assembly - Average of 3 numbers
; Assemble: nasm -f elf64 avg.asm -o avg.o
; Link: ld avg.o -o avg
; Run: ./avg

section .bss
    num1 resb 10
    num2 resb 10
    num3 resb 10
    result resb 10

section .data
    prompt1 db "Enter first number: ", 0
    prompt1_len equ $-prompt1
    prompt2 db "Enter second number: ", 0
    prompt2_len equ $-prompt2
    prompt3 db "Enter third number: ", 0
    prompt3_len equ $-prompt3
    out_msg db "Average is: ", 0
    out_len equ $-out_msg

section .text
    global _start

_start:
    ; --- Read first number ---
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, prompt1
    mov rdx, prompt1_len
    syscall

    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, num1
    mov rdx, 10
    syscall

    call str2int
    mov rbx, rax        ; store first number in rbx

    ; --- Read second number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt2
    mov rdx, prompt2_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num2
    mov rdx, 10
    syscall

    call str2int
    add rbx, rax        ; sum += second number

    ; --- Read third number ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt3
    mov rdx, prompt3_len
    syscall

    mov rax, 0
    mov rdi, 0
    mov rsi, num3
    mov rdx, 10
    syscall

    call str2int
    add rbx, rax        ; sum += third number

    ; --- Calculate average ---
    mov rax, rbx
    mov rcx, 3
    cqo                 ; extend rax to rdx:rax
    idiv rcx            ; rax = rax / 3, remainder in rdx

    ; --- Convert integer to string ---
    mov rdi, result
    call int2str

    ; --- Print output ---
    mov rax, 1
    mov rdi, 1
    mov rsi, out_msg
    mov rdx, out_len
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 10
    syscall

    ; --- Exit ---
    mov rax, 60
    xor rdi, rdi
    syscall

; --- Subroutine: string to integer ---
str2int:
    xor rax, rax
    xor rcx, rcx
.next_char:
    mov cl, byte [rsi]
    cmp cl, 10        ; newline
    je .done
    cmp cl, 0
    je .done
    sub cl, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .next_char
.done:
    ret

; --- Subroutine: integer to string ---
int2str:
    mov rbx, 10
    xor rcx, rcx        ; digit counter
.next_digit:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .next_digit

    mov rdi, rdi        ; destination buffer
.print_digit:
    pop rax
    mov [rdi], al
    inc rdi
    loop .print_digit
    mov byte [rdi], 10  ; newline
    ret

