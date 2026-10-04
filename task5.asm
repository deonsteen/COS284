bits 64
; Task 5: double weighted_rating(Book *books, long n)
; Returns  sum(rating_i * pages_i) / sum(pages_i)
;
; struct Book layout (24 bytes):
;   offset  0: int    id      (4 bytes, then 4 bytes padding)
;   offset  8: double rating  (8 bytes)
;   offset 16: int    pages   (4 bytes, then 4 bytes padding)
;
; Inputs:  rdi  = pointer to the first Book
;          rsi  = n (number of books, at least 1)
; Output:  xmm0 = weighted rating
;
; Registers used:
;   xmm0 = running top sum    (rating * pages, added up)
;   xmm2 = running bottom sum (pages, added up, as a double)
;   xmm1 = this book's rating
;   xmm3 = this book's pages, as a double
;   rcx  = this book's pages, as an integer

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
