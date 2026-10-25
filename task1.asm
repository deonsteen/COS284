; DFA* readDfa(const char* filename)
;
; DFA layout (32 bytes):  states @0, transitions @8, numStates @16,
;                         numTransitions @20, startState @24
; State (8 bytes):        id @0, isAccepting @4
; Transition (12 bytes):  from @0, to @4, symbol @8
;
; Callee-saved registers (survive our calls into libc):
;   rbx = FILE*, r12 = DFA*, r13d = loop counter,
;   r14 = pointer to current State/Transition, r15d = accepting id being parsed
; Locals: [rsp] int, [rsp+4] int, [rsp+8] char  (fscanf writes into these)
global readDfa
extern fopen, fclose, fscanf, fgetc, malloc, calloc

section .rodata
modeRead    db "r", 0
fmtCounts   db "%d,%d", 0
fmtState    db "%d,", 0
fmtTrans    db " %d,%d,%c", 0

section .text
readDfa:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24                 ; 6 pushes + 24 = 72 + ret addr 8 = 80 -> aligned

    ; FILE* f = fopen(filename, "r");  if (!f) return NULL;
    lea rsi, [rel modeRead]     ; rdi already holds filename
    call fopen
    test rax, rax
    jz .fail
    mov rbx, rax

    ; DFA* d = malloc(sizeof(DFA));
    mov edi, 32
    call malloc
    mov r12, rax

    ; ---- line 1: numStates,numTransitions ----
    mov rdi, rbx
    lea rsi, [rel fmtCounts]
    lea rdx, [rsp]
    lea rcx, [rsp+4]
    xor eax, eax                ; varargs: al = number of vector regs used
    call fscanf
    mov eax, [rsp]
    mov [r12+16], eax           ; numStates
    mov eax, [rsp+4]
    mov [r12+20], eax           ; numTransitions
    mov dword [r12+24], 0       ; startState is always 0

    ; calloc zeroes memory, so every isAccepting starts as false
    movsxd rdi, dword [r12+16]
    mov esi, 8
    call calloc
    mov [r12], rax              ; states

    movsxd rdi, dword [r12+20]
    mov esi, 12
    call calloc
    mov [r12+8], rax            ; transitions

    ; ---- line 2: state ids ----
    xor r13d, r13d
    mov r14, [r12]
.stateLoop:
    cmp r13d, [r12+16]
    jge .stateDone
    mov rdi, rbx
    lea rsi, [rel fmtState]     ; "%d," eats the number and a comma if present
    lea rdx, [rsp]
    xor eax, eax
    call fscanf
    mov eax, [rsp]
    mov [r14], eax              ; states[i].id
    add r14, 8
    inc r13d
    jmp .stateLoop
.stateDone:

    ; skip the rest of line 2 (the '\n' fscanf left behind)
.skipLine:
    mov rdi, rbx
    call fgetc
    cmp eax, -1                 ; EOF
    je .acceptDone
    cmp eax, 10                 ; '\n'
    jne .skipLine

    ; ---- line 3: accepting ids, parsed one char at a time ----
    ; r15d = number being built, -1 means "no digits seen yet"
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
    xor r15d, r15d              ; first digit of a new number
.addDigit:
    imul r15d, r15d, 10
    add r15d, eax
    jmp .acceptLoop

.notDigit:                      ; ',', '\r', '\n' or EOF ends a number
    test r15d, r15d
    js .checkEnd                ; no number pending
    cmp r15d, [r12+16]
    jge .clearNum               ; ignore ids outside 0..numStates-1
    mov rcx, [r12]
    mov byte [rcx + r15*8 + 4], 1   ; states[id].isAccepting = true
.clearNum:
    mov r15d, -1
.checkEnd:
    cmp eax, 10                 ; '\n'
    je .acceptDone
    cmp eax, -1                 ; EOF
    je .acceptDone
    jmp .acceptLoop
.acceptDone:

    ; ---- remaining lines: from,to,symbol ----
    xor r13d, r13d
    mov r14, [r12+8]
.transLoop:
    cmp r13d, [r12+20]
    jge .transDone
    mov rdi, rbx
    lea rsi, [rel fmtTrans]     ; leading space skips the previous newline
    lea rdx, [rsp]
    lea rcx, [rsp+4]
    lea r8, [rsp+8]
    xor eax, eax
    call fscanf
    cmp eax, 3                  ; stop if the line didn't parse
    jne .transDone
    mov eax, [rsp]
    mov [r14], eax              ; from
    mov eax, [rsp+4]
    mov [r14+4], eax            ; to
    mov al, [rsp+8]
    mov [r14+8], al             ; symbol
    add r14, 12
    inc r13d
    jmp .transLoop
.transDone:

    mov rdi, rbx
    call fclose
    mov rax, r12                ; return d
    jmp .end

.fail:
    xor eax, eax                ; return NULL

.end:
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
