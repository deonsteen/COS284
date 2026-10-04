bits 64
global count_above

section .text

count_above:
    mov rax, 0

.loop:
    movsd  xmm1, qword[rdi + 8]
    comisd xmm1, xmm0
    jbe .next
    inc rax

.next:
    add rdi, 24
    dec rsi
    jnz .loop
    ret
