bits 64
global simulateDfa
section .text
simulateDfa:
    mov r8, [rdi+8]
    mov r9d, [rdi+20]
    mov eax, [rdi+24]

.nextChar:
    movzx edx, byte [rsi]
    test dl, dl
    jz .endOfInput

    xor ecx, ecx
    mov r10, r8
.search:
    cmp ecx, r9d
    jge .reject
    cmp [r10], eax
    jne .skip
    cmp [r10+8], dl
    jne .skip
    mov eax, [r10+4]
    inc rsi
    jmp .nextChar
.skip:
    add r10, 12
    inc ecx
    jmp .search

.endOfInput:
    mov r8, [rdi]
    mov r9d, [rdi+16]
    xor ecx, ecx
.findState:
    cmp ecx, r9d
    jge .reject
    cmp [r8], eax
    je .found
    add r8, 8
    inc ecx
    jmp .findState
.found:
    movzx eax, byte [r8+4]
    ret

.reject:
    xor eax, eax
    ret
