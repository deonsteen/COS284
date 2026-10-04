bits 64
global weighted_rating

section .text

weighted_rating:
    pxor xmm0, xmm0
    pxor xmm2, xmm2
.loop:
    movsd xmm1, qword[rdi + 8]
    movsxd rcx, dword[rdi + 16]
    cvtsi2sd xmm3, rcx
    addsd xmm2, xmm3
    mulsd xmm1, xmm3
    addsd xmm0, xmm1
    add rdi, 24
    dec rsi
    jnz .loop
    divsd xmm0, xmm2

    ret
