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
    jl .not_letter
    cmp al, 'Z'
    jle .do_upper
    cmp al, 'a'
    jl .not_letter
    cmp al, 'z'
    jle .do_lower
    jmp .not_letter

.do_upper:
    sub al, 'A'
    movzx eax, al
    add eax, 3
    cmp eax, 26
    jl .upper_ok
    sub eax, 26
.upper_ok:
    add eax, 'A'
    mov [buffer + r13], al
    jmp .not_letter

.do_lower:
    sub al, 'a'
    movzx eax, al
    add eax, 3
    cmp eax, 26
    jl .lower_ok
    sub eax, 26
.lower_ok:
    add eax, 'a'
    mov [buffer + r13], al

.not_letter:
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
