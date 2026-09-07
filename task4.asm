section .data
    hex_digits db "0123456789abcdef"

section .bss
    in_buffer  resb 4096
    out_buffer resb 8192

section .text
    global _start

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, in_buffer
    mov rdx, 4096
    syscall

    mov r12, rax
    xor r13, r13
    xor r15, r15

.transform_loop:
    cmp r13, r12
    jge .write_output

    mov al, [in_buffer + r13]
    xor al, 0x2a
    mov bl, al

    mov cl, bl
    shr cl, 4
    movzx rcx, cl
    mov dl, [hex_digits + rcx]
    mov [out_buffer + r15], dl
    inc r15

    mov cl, bl
    and cl, 0x0f
    movzx rcx, cl
    mov dl, [hex_digits + rcx]
    mov [out_buffer + r15], dl
    inc r15

    inc r13
    jmp .transform_loop

.write_output:
    mov byte [out_buffer + r15], 10
    inc r15

    mov rax, 1
    mov rdi, 1
    mov rsi, out_buffer
    mov rdx, r15
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
