bits 64
global readDfa
extern fopen, fclose, fscanf, fgetc, malloc, calloc

section .rodata
modeRead    db "r", 0 ; mode for fopen
fmtCounts   db "%d,%d", 0 ; reads line 1: numStates,numTransitions
fmtState    db "%d,", 0 ; reads one id and a trailing comma
fmtTrans    db " %d,%d,%c", 0 ;leading space to ignore new lnie character and any whitespaces

section .text
readDfa:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24 ; reserves space where fscanf can write its results

    lea rsi, [rel modeRead]
    call fopen
    test rax, rax
    jz .fail
    mov rbx, rax

    mov edi, 32
    call malloc
    mov r12, rax

    mov rdi, rbx
    lea rsi, [rel fmtCounts]
    lea rdx, [rsp]
    lea rcx, [rsp+4]
    xor eax, eax
    call fscanf
    mov eax, [rsp]
    mov [r12+16], eax
    mov eax, [rsp+4]
    mov [r12+20], eax
    mov dword [r12+24], 0

    movsxd rdi, dword [r12+16]
    mov esi, 8
    call calloc
    mov [r12], rax

    movsxd rdi, dword [r12+20]
    mov esi, 12
    call calloc
    mov [r12+8], rax

    xor r13d, r13d
    mov r14, [r12]
.stateLoop:
    cmp r13d, [r12+16]
    jge .stateDone
    mov rdi, rbx
    lea rsi, [rel fmtState]
    lea rdx, [rsp]
    xor eax, eax
    call fscanf
    mov eax, [rsp]
    mov [r14], eax
    add r14, 8
    inc r13d
    jmp .stateLoop
.stateDone:

.skipLine:
    mov rdi, rbx
    call fgetc
    cmp eax, -1
    je .acceptDone
    cmp eax, 10
    jne .skipLine

    mov r15d, -1
.acceptLoop:
    mov rdi, rbx
    call fgetc
    cmp eax, '0'
    jl .notDigit
    cmp eax, '9'
    jg .notDigit
    sub eax, '0'
    test r15d, r15d
    jns .addDigit
    xor r15d, r15d
.addDigit:
    imul r15d, r15d, 10
    add r15d, eax
    jmp .acceptLoop

.notDigit:
    test r15d, r15d
    js .checkEnd
    cmp r15d, [r12+16]
    jge .clearNum
    mov rcx, [r12]
    mov byte [rcx + r15*8 + 4], 1
.clearNum:
    mov r15d, -1
.checkEnd:
    cmp eax, 10
    je .acceptDone
    cmp eax, -1
    je .acceptDone
    jmp .acceptLoop
.acceptDone:

    xor r13d, r13d
    mov r14, [r12+8]
.transLoop:
    cmp r13d, [r12+20]
    jge .transDone
    mov rdi, rbx
    lea rsi, [rel fmtTrans]
    lea rdx, [rsp]
    lea rcx, [rsp+4]
    lea r8, [rsp+8]
    xor eax, eax
    call fscanf
    cmp eax, 3
    jne .transDone
    mov eax, [rsp]
    mov [r14], eax
    mov eax, [rsp+4]
    mov [r14+4], eax
    mov al, [rsp+8]
    mov [r14+8], al
    add r14, 12
    inc r13d
    jmp .transLoop
.transDone:

    mov rdi, rbx
    call fclose
    mov rax, r12
    jmp .end

.fail:
    xor eax, eax

.end:
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
