bits 64
global best_book

section .text

best_book:
    mov rax, rdi
    movsd xmm0, qword[rdi + 8]

.loop:
    movsd xmm1, qword[rdi + 8]
    comisd xmm1, xmm0
    jbe .next

    movsd xmm0, xmm1 
    mov rax, rdi   

.next:
    add rdi, 24
    dec rsi
    jnz .loop

ret