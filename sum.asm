section .data
    ; Prompt messages
    prompt1 db  "Enter first number: ", 0
    prompt1_len equ $ - prompt1 - 1  ; Subtract 1 to exclude null terminator
    
    prompt2 db  "Enter second number: ", 0
    prompt2_len equ $ - prompt2 - 1
    
    ; Result messages
    num1_msg db  "First number entered: ", 0
    num1_msg_len equ $ - num1_msg - 1
    
    num2_msg db  "Second number entered: ", 0
    num2_msg_len equ $ - num2_msg - 1
    
    sum_msg db  "The sum of ", 0
    sum_msg_len equ $ - sum_msg - 1
    
    and_msg db  " and ", 0
    and_msg_len equ $ - and_msg - 1
    
    is_msg  db  " is: ", 0
    is_msg_len equ $ - is_msg - 1
    
    newline db  10
    newline_len equ $ - newline

section .bss
    num1    resq 1          ; Space for first number
    num2    resq 1          ; Space for second number
    result  resq 1          ; Space for result
    buffer  resb 21         ; Buffer for input (20 digits + null)
    input_len resq 1        ; Length of input

section .text
    global _start

_start:
    ; Prompt for first number
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, prompt1
    mov     rdx, prompt1_len
    syscall
    
    ; Read first number
    call    read_number
    mov     [num1], rax     ; Store first number
    
    ; Display what was entered
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, num1_msg
    mov     rdx, num1_msg_len
    syscall
    
    mov     rax, [num1]
    call    print_number
    call    print_newline
    
    ; Prompt for second number
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, prompt2
    mov     rdx, prompt2_len
    syscall
    
    ; Read second number
    call    read_number
    mov     [num2], rax     ; Store second number
    
    ; Display what was entered
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, num2_msg
    mov     rdx, num2_msg_len
    syscall
    
    mov     rax, [num2]
    call    print_number
    call    print_newline
    
    ; Add the two numbers
    mov     rax, [num1]
    mov     rbx, [num2]
    add     rax, rbx
    mov     [result], rax
    
    ; Display the complete result message
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, sum_msg
    mov     rdx, sum_msg_len
    syscall
    
    ; Display first number in result
    mov     rax, [num1]
    call    print_number
    
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, and_msg
    mov     rdx, and_msg_len
    syscall
    
    ; Display second number in result
    mov     rax, [num2]
    call    print_number
    
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, is_msg
    mov     rdx, is_msg_len
    syscall
    
    ; Display the result
    mov     rax, [result]
    call    print_number
    call    print_newline
    
    ; Exit program
    mov     rax, 60         ; sys_exit
    xor     rdi, rdi        ; exit code 0
    syscall

; Function to read a number from stdin
read_number:
    ; Read input from stdin
    mov     rax, 0          ; sys_read
    mov     rdi, 0          ; stdin
    mov     rsi, buffer
    mov     rdx, 20         ; max length
    syscall
    
    ; Check if we got any input
    cmp     rax, 0
    jle     .no_input
    
    mov     [input_len], rax ; Save length
    
    ; Convert string to integer
    mov     rsi, buffer     ; Pointer to string
    mov     rcx, rax        ; Length
    xor     rax, rax        ; Clear result
    xor     rbx, rbx        ; Clear temporary
    xor     rdx, rdx        ; Clear digit
    
.convert_loop:
    mov     bl, [rsi]       ; Get current character
    cmp     bl, 10          ; Check for newline
    je      .done
    cmp     bl, 13          ; Check for carriage return
    je      .done
    cmp     bl, '0'         ; Validate digit
    jb      .skip
    cmp     bl, '9'
    ja      .skip
    
    sub     bl, '0'         ; Convert ASCII to digit
    imul    rax, 10         ; Multiply current result by 10
    add     rax, rbx        ; Add new digit
    
.skip:
    inc     rsi
    loop    .convert_loop
    
.done:
    ret

.no_input:
    xor     rax, rax        ; Return 0 if no input
    ret

; Function to print a number from RAX
print_number:
    push    rax             ; Save number
    push    rdi
    push    rsi
    push    rdx
    
    mov     rdi, buffer
    call    int_to_string
    
    ; Calculate string length
    mov     rsi, rdi        ; Start of string (returned from int_to_string)
    mov     rdx, buffer
    add     rdx, 21         ; End of buffer
    sub     rdx, rsi        ; RDX = length
    
    ; Write the number
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    syscall
    
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax             ; Restore number
    ret

; Function to convert integer to string
; Input: RAX = number
; Output: RDI = pointer to start of string in buffer
int_to_string:
    push    rbx
    push    rdx
    push    rsi
    
    mov     rbx, 10         ; Base 10
    mov     rdi, buffer
    add     rdi, 20         ; Point to end of buffer
    mov     byte [rdi], 0   ; Null terminator
    
    test    rax, rax        ; Check if number is zero
    jnz     .not_zero
    dec     rdi
    mov     byte [rdi], '0'
    jmp     .done
    
.not_zero:
    ; Handle positive numbers
    
.convert_loop:
    dec     rdi
    xor     rdx, rdx        ; Clear RDX for division
    div     rbx             ; RAX = quotient, RDX = remainder
    add     dl, '0'         ; Convert to ASCII
    mov     [rdi], dl
    test    rax, rax        ; Check if quotient is zero
    jnz     .convert_loop
    
.done:
    ; RDI now points to the start of the string
    pop     rsi
    pop     rdx
    pop     rbx
    ret

; Function to print newline
print_newline:
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    mov     rsi, newline
    mov     rdx, newline_len
    syscall
    ret
