.text


#long HashTable_ASM_OPT_lookup(void * table, char * word, long * value);
.globl HashTable_ASM_OPT_lookup
HashTable_ASM_OPT_lookup:
        pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r13
    pushq %r14
    pushq %r15

    movq %rdi, %rbx   # rbx contains the table
    movq %rsi, %r13   # r13 contains the word
    movq %rdx, %r14   # r14 contains the value

    movq $1, %rax

while12:
        movq $0, %rcx
        movb (%rsi), %cl
        cmpq $0, %rcx
        je afterwhile12
        movq  %rax, %rdx
        shlq $5, %rax        # Perform a left shift by 5 (i.e., multiply hashNum by 32)
        subq %rdx, %rax 
        addq %rcx, %rax
        addq $1, %rsi
        jmp while12


afterwhile12:
            cmpq $0, %rax
            jge nonneg2
            notq  %rax
            addq  $1, %rax


nonneg2:
        movq 48(%rdi), %rcx           #Load the divisor
        addq $-1, %rcx                 # rcx = rcx - 1, for the AND operation
        andq %rcx, %rax               # Calculate the remainder

    imulq $24, %rax
    addq 56(%rbx), %rax
    movq 16(%rax), %r15

while2:
    cmpq $0, %r15
    je nullele
    movq (%r15), %rdi
    movq %r13, %rsi
my_strcmp2:
    movq  $0, %rax
whilestr2:
    movb  (%rdi), %al
    movb  (%rsi), %bl
    cmpb  %bl, %al
    jne   endfunc2
    cmpb $0, %al
    je    endfunc2
    addq  $1, %rsi
    addq  $1, %rdi
    jmp   whilestr2

endfunc2:
    subb  %bl, %al
    cmpq $0, %rax
    je afterwhile
    
    movq 16(%r15), %r15
    jmp while2


nullele:
    movq $0, %rax
    jmp exit

afterwhile:
    movq 8(%r15), %rcx
    movq %rcx, (%r14)
    movq $1, %rax

exit:
    popq %r15
    popq %r14
    popq %r13
    popq %rbx
    leave
    ret

#long HashTable_ASM_OPT_update(void * table, char * word, long value);
.globl HashTable_ASM_OPT_update
HashTable_ASM_OPT_update:
        pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %r15

    movq %rdi, %r12   # r12 = table (hashTable)
    movq %rsi, %r13   # r13 = word
    movq %rdx, %r14   # r14 = value

    movq $1, %rax

while123:
        movq $0, %rcx
        movb (%rsi), %cl
        cmpq $0, %rcx
        je afterwhile123
         movq  %rax, %rdx
        shlq $5, %rax        # Perform a left shift by 5 (i.e., multiply hashNum by 32)
         subq %rdx, %rax 

        addq %rcx, %rax
        addq $1, %rsi
        jmp while123


afterwhile123:
            cmpq $0, %rax
            jge nonneg23
            notq  %rax
            addq  $1, %rax


nonneg23:
       movq $0, %rdx
        movq 48(%rdi), %rcx
        divq %rcx
        movq %rdx, %rax


        movq %rax, %rbx

    imulq $24, %rbx
    addq 56(%r12), %rbx
    movq %rbx, %r15

while3:
    movq 16(%r15), %r9  # rsi = elem->next
    cmpq $0, %r9
    je not_found

    movq (%r9), %rdi    # rdi = elem->next->word
    movq %r13, %rsi
my_strcmp:
    movq  $0, %rax
whilestr:
    movb  (%rdi), %al
    movb  (%rsi), %bl

    cmpb  %bl, %al
    jne   endfunc

    cmpb $0, %al
    je    endfunc

    addq  $1, %rdi
    addq  $1, %rsi
    jmp   whilestr

endfunc:
    subb  %bl, %al
    cmpq $0, %rax
    je found

    movq 16(%r15), %r15      # elem = elem->next
    jmp while3

found:
    movq %r14, 8(%r9)   # elem->next->value = value
    movq $1, %rax        # return true
    jmp cleanup

not_found:
    movq $24, %rdi       # sizeof(struct HashTableElement)
    call malloc
    cmpq $0, %rax
    je malloc_error

    movq %rax, 16(%r15)
    movq 16(%r15), %rbx
    movq %r13, %rdi
    call strdup


    movq %rax, (%rbx)
    movq %r14, 8(%rbx)
    movq $0, 16(%rbx)
    movq $0, %rax
    jmp cleanup

malloc_error:
    movq $1, %rdi
    call perror
    movq $1, %rdi
    call exit

cleanup:
    popq %r15
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    leave
    ret

    