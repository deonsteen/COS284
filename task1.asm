section .bss
    buffer resb 4096

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 4096
    syscall

    mov r12, rax
    xor r13, r13

.transform_loop:
    cmp r13, r12
    jge .write_output

    mov al, [buffer + r13]

    cmp al, 'A'
    jl .not_upper
    cmp al, 'Z'
    jg .not_upper
    xor al, 0x20
    jmp .store

.not_upper:
    cmp al, 'a'
    jl .store
    cmp al, 'z'
    jg .store
    xor al, 0x20

.store:
    mov [buffer + r13], al

    inc r13
    jmp .transform_loop

.write_output:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, r12
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
