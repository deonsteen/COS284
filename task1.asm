bits 64
global total_pages

section .text

total_pages:
    mov rax, 0

.loop:
    movsxd rcx, dword [rdi + 16]
    add rax, rcx
    add rdi, 24
    dec rsi
    cmp rsi, 0
    jne .loop
    ret
