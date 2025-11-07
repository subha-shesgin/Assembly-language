; factorial.asm - Compute factorial of a number
; NASM 64-bit Linux

section .bss
    num resb 20
    result resb 50      ; to store factorial as string (big enough)

section .data
    prompt db "Enter a number: ",0
    prompt_len equ $-prompt
    newline db 10,0

section .text
    global _start

_start:
    ; --- Prompt user ---
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; --- Read input ---
    mov rax, 0
    mov rdi, 0
    mov rsi, num
    mov rdx, 20
    syscall

    ; --- Convert string to integer ---
    mov rsi, num
    call str2int
    mov rbx, r8       ; n in rbx

    ; --- Compute factorial ---
    mov rax, 1        ; factorial accumulator in rax
    cmp rbx, 0
    je print_result   ; 0! = 1

fact_loop:
    imul rax, rbx     ; rax = rax * rbx
    dec rbx
    cmp rbx, 0
    jne fact_loop

print_result:
    mov r8, rax       ; store factorial in r8
    mov rdi, result
    call int2str

    ; --- Print factorial ---
    mov rax, 1
    mov rdi, 1
    mov rsi, result
    mov rdx, 50
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
