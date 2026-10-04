; Task 1: long total_pages(Book *books, long n)
; Returns the sum of the pages field over all books.
;
; struct Book layout (24 bytes):
;   offset  0: int    id      (4 bytes, then 4 bytes padding)
;   offset  8: double rating  (8 bytes)
;   offset 16: int    pages   (4 bytes, then 4 bytes padding)
;
; Inputs:  rdi = pointer to the first Book
;          rsi = n (number of books, at least 1)
; Output:  rax = total pages

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
