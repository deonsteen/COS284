bits 64
global average_rating

section .text

average_rating:
    ; sets running sum to 0.0
	pxor xmm0, xmm0

	cvtsi2sd xmm1,rsi

.loop:
	addsd xmm0, qword[rdi + 8]
    add rdi, 24
    dec rsi
    jnz .loop

    divsd xmm0, xmm1
	ret
