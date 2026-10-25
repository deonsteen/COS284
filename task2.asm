bits 64
global simulateDfa
section .text
simulateDfa:
    mov r8, [rdi+8]             ; transitions
    mov r9d, [rdi+20]           ; numTransitions
    mov eax, [rdi+24]           ; cur = startState

.nextChar:
    movzx edx, byte [rsi]       ; c = *input
    test dl, dl
    jz .endOfInput              ; hit '\0'

    ; look for a transition with from == cur && symbol == c
    xor ecx, ecx
    mov r10, r8
.search:
    cmp ecx, r9d
    jge .reject                 ; no transition for this char -> reject
    cmp [r10], eax              ; from == cur ?
    jne .skip
    cmp [r10+8], dl             ; symbol == c ?
    jne .skip
    mov eax, [r10+4]            ; cur = to
    inc rsi                     ; input++
    jmp .nextChar
.skip:
    add r10, 12                 ; next Transition
    inc ecx
    jmp .search

.endOfInput:
    ; find the State whose id == cur and return its isAccepting
    mov r8, [rdi]               ; states
    mov r9d, [rdi+16]           ; numStates
    xor ecx, ecx
.findState:
    cmp ecx, r9d
    jge .reject
    cmp [r8], eax               ; id == cur ?
    je .found
    add r8, 8                   ; next State
    inc ecx
    jmp .findState
.found:
    movzx eax, byte [r8+4]      ; return isAccepting
    ret

.reject:
    xor eax, eax                ; return false
    ret
