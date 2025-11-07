global _start

section .text

_start:
    mov rax, 1              ; syscall number for write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, message        ; address of the string
    mov rdx, message_length ; length of the string
    syscall                 ; invoke the syscall

    ; Exit gracefully
    mov rax, 60             ; syscall number for exit
    xor rdi, rdi            ; exit code 0
    syscall

section .data

message: db "Hello World!", 0xA
message_length: equ $ - message

