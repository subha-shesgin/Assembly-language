; Enter elements for Matrix 1 (3x3):
; 5 8 3
; 2 9 4
; 7 1 6
; Enter elements for Matrix 2 (3x3):
; 2 3 1
; 4 2 3
; 1 5 2

; Difference of matrices (Matrix1 - Matrix2):
; 3 5 2
; -2 7 1
; 6 -4 4


section .data
    ; Matrix dimensions
    rows equ 3
    cols equ 3
    matrix_size equ rows * cols
    
    ; Prompt messages
    msg_matrix1 db "Enter elements for Matrix 1 (3x3):", 10, 0
    msg_matrix2 db 10, "Enter elements for Matrix 2 (3x3):", 10, 0
    msg_result db 10, "Difference of matrices (Matrix1 - Matrix2):", 10, 0
    space db " ", 0
    newline db 10, 0
    
    ; Buffers
    number_buffer times 12 db 0
    input_buffer times 100 db 0  ; Larger buffer for row input

section .bss
    matrix1 resd 9      ; Reserve space for 3x3 matrix (9 doublewords)
    matrix2 resd 9
    result resd 9

section .text
    global _start

; Function to read a row of integers
read_row:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    
    ; Read entire line
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 100
    syscall
    
    mov rsi, input_buffer  ; pointer to input
    mov rdi, r8           ; matrix pointer
    mov r9, 0             ; numbers read counter
    
parse_loop:
    ; Skip whitespace
    cmp byte [rsi], ' '
    je skip_space
    cmp byte [rsi], 9    ; tab
    je skip_space
    cmp byte [rsi], 10   ; newline
    je parse_done
    cmp byte [rsi], 0    ; null terminator
    je parse_done
    
    ; Convert number
    mov rax, 0
    mov rcx, 0           ; negative flag
    mov bl, byte [rsi]
    cmp bl, '-'
    jne convert_digit
    mov rcx, 1
    inc rsi
    
convert_digit:
    movzx rbx, byte [rsi]
    cmp rbx, '0'
    jl number_done
    cmp rbx, '9'
    jg number_done
    sub rbx, '0'
    imul rax, 10
    add rax, rbx
    inc rsi
    jmp convert_digit
    
number_done:
    test rcx, rcx
    jz store_number
    neg rax
    
store_number:
    mov [rdi], eax      ; store in matrix
    add rdi, 4
    inc r9
    
    ; Check if we've read enough numbers
    cmp r9, cols
    jge parse_done
    
    jmp parse_loop
    
skip_space:
    inc rsi
    jmp parse_loop
    
parse_done:
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Function to read a matrix
read_matrix:
    push r8
    push r9
    
    mov r8, rdi        ; matrix pointer
    mov r9, 0          ; row counter
    
read_row_loop:
    call read_row      ; read one row
    
    add r8, cols * 4   ; move to next row
    inc r9
    cmp r9, rows
    jl read_row_loop
    
    pop r9
    pop r8
    ret

; Function to print integer
print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    mov rdi, number_buffer + 11
    mov byte [rdi], 0
    mov rbx, 10
    
    test eax, eax
    jns convert_loop
    neg eax
    push rax
    mov al, '-'
    call print_char
    pop rax
    
convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz convert_loop
    
    ; Print the number
    mov rsi, rdi
    mov rdx, number_buffer + 11
    sub rdx, rsi
    mov rax, 1
    mov rdi, 1
    syscall
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Function to print single character
print_char:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov [number_buffer], al
    mov rax, 1
    mov rdi, 1
    mov rsi, number_buffer
    mov rdx, 1
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; Function to print string
print_string:
    push rax
    push rdi
    push rsi
    push rdx
    push rcx
    
    mov rsi, rax        ; string pointer
    mov rdx, 0          ; length counter
    
str_len_loop:
    cmp byte [rsi + rdx], 0
    je str_len_done
    inc rdx
    jmp str_len_loop
    
str_len_done:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

_start:
    ; Read Matrix 1
    mov rax, msg_matrix1
    call print_string
    mov rdi, matrix1
    call read_matrix

    ; Read Matrix 2
    mov rax, msg_matrix2
    call print_string
    mov rdi, matrix2
    call read_matrix

    ; Calculate DIFFERENCE of matrices (Matrix1 - Matrix2)
    mov rcx, 0
subtract_loop:
    mov eax, [matrix1 + rcx * 4]  ; Load from Matrix1
    sub eax, [matrix2 + rcx * 4]  ; Subtract Matrix2
    mov [result + rcx * 4], eax   ; Store result
    inc rcx
    cmp rcx, matrix_size
    jl subtract_loop

    ; Print result message
    mov rax, msg_result
    call print_string

    ; Print result matrix using nested loops
    mov r8, 0          ; row counter
row_loop:
    mov r9, 0          ; column counter
col_loop:
    ; Calculate index = row * cols + column
    mov rax, r8        ; row
    mov rbx, cols
    mul rbx            ; row * cols
    add rax, r9        ; + column
    
    ; Print element
    mov eax, [result + rax * 4]
    call print_int
    
    ; Print space (except after last column)
    inc r9
    cmp r9, cols
    jge no_space
    
    mov al, ' '
    call print_char
    jmp col_loop
    
no_space:
    ; Print newline after each row
    mov al, 10
    call print_char
    
    inc r8
    cmp r8, rows
    jl row_loop

    ; Exit program
    mov rax, 60
    xor rdi, rdi
    syscall