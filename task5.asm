section .bss
    buffer   resb 4096
    keyword  resb 256

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

    xor r14, r14

.copy_keyword:
    mov al, [buffer + r13]
    cmp al, 10
    je .keyword_done
    mov [keyword + r14], al
    inc r14
    inc r13
    jmp .copy_keyword

.keyword_done:
    inc r13
    mov rbx, r13

    xor r15, r15

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
    mov cl, [keyword + r15]
    sub cl, 'a'
    sub al, 'A'
    movzx eax, al
    movzx ecx, cl
    add eax, ecx
    cmp eax, 26
    jl .upper_ok
    sub eax, 26
.upper_ok:
    add eax, 'A'
    mov [buffer + r13], al
    jmp .advance_keyword

.do_lower:
    mov cl, [keyword + r15]
    sub cl, 'a'
    sub al, 'a'
    movzx eax, al
    movzx ecx, cl
    add eax, ecx
    cmp eax, 26
    jl .lower_ok
    sub eax, 26
.lower_ok:
    add eax, 'a'
    mov [buffer + r13], al

.advance_keyword:
    inc r15
    cmp r15, r14
    jne .not_letter
    xor r15, r15

.not_letter:
    inc r13
    jmp .transform_loop

.write_output:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    add rsi, rbx
    mov rdx, r12
    sub rdx, rbx
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
