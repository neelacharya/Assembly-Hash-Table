
.text

#long HashTable_ASM_hash(void * table, char * word); 
.globl HashTable_ASM_hash
HashTable_ASM_hash:
	pushq %rbp
	movq %rsp, %rbp
  #struct HashTable *hashTable = table;
  #table - %rdi
  #word - %rsi
  #hashNum %rax
  #temporal %rcx, %r8
  
    

	movq $1, %rax

while1: 
        movq $0, %rcx
        movb (%rsi), %cl
        cmpq $0, %rcx
        je afterwhile1
        imulq $31, %rax
        addq %rcx, %rax
        addq $1, %rsi
        jmp while1


afterwhile1: 
            cmpq $0, %rax
            jge nonneg
            movq $0, %rdx
            imulq $-1, %rax

nonneg: 
        movq $0, %rdx
        movq 48(%rdi), %rcx
        divq %rcx
        movq %rdx, %rax
        movq $0, %rdx
        movq $1, %rcx
        idivq %rcx
    
	leave
	ret

#long HashTable_ASM_lookup(void * table, char * word, long * value);
.globl HashTable_ASM_lookup
HashTable_ASM_lookup:
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
    call HashTable_ASM_hash

    imulq $24, %rax
    addq 56(%rbx), %rax
    movq 16(%rax), %r15

while2: 
    cmpq $0, %r15
    je nullele
    movq (%r15), %rdi
    movq %r13, %rsi
    call strcmp
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



#long HashTable_ASM_update(void * table, char * word, long value); 
.globl HashTable_ASM_update
HashTable_ASM_update:
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
    call HashTable_ASM_hash
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
    call strcmp
    testq %rax, %rax
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


