bits 64
; Task 4: Book *best_book(Book *books, long n)
; Returns a pointer to the book with the highest rating.
; If several books share the highest rating, returns the FIRST of them.
;
; struct Book layout (24 bytes):
;   offset  0: int    id      (4 bytes, then 4 bytes padding)
;   offset  8: double rating  (8 bytes)
;   offset 16: int    pages   (4 bytes, then 4 bytes padding)
;
; Inputs:  rdi = pointer to the first Book
;          rsi = n (number of books, at least 1)
; Output:  rax = pointer to the best Book (an address, not a rating)

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