section .data
input db "10+2*3", 0

section .bss
   buffer resb 32

section .text

global _start

_start:
    mov rbx, input

    call parse_expression

    mov r12, rax
    call print_number

    jmp done

next:

    mov al, [rbx]
    cmp al, 0
    je done
    
    call is_digit 
    mov al, [rbx]
    movzx rdi, al
    call print_char

    inc rbx 

    jmp next


is_digit:
    cmp al, '0'
    jb .no

    cmp al, '9'
    ja .no

    mov rax, 1
    ret

.no:
    mov rax, 0
    ret
      
parse_number:
    xor rdx, rdx

.loop:
    mov al, [rbx]

    call is_digit
    cmp rax, 1
    jne .done

    mov al, [rbx]
    movzx rcx, al
    sub rcx, '0'

    imul rdx, 10
    add rdx, rcx

    inc rbx
    jmp .loop

.done:
    mov rax, rdx
    ret


parse_term:
    call parse_number
    mov r12, rax

.loop:
    call skip_space

    mov al, [rbx]

    cmp al, '*'
    je .multiply

    cmp al, '/'
    je .divide

    mov rax, r12
    ret

.multiply:
    inc rbx
    call skip_space
    call parse_number
    imul r12, rax
    jmp .loop

.divide:
    inc rbx
    call skip_space
    call parse_number

    mov rcx, rax
    mov rax, r12
    xor rdx, rdx
    div rcx
    mov r12, rax

    jmp .loop

parse_expression:
    call parse_term
    mov r13, rax

.loop:
    call skip_space

    mov al, [rbx]

    cmp al, '+'
    je .add

    cmp al, '-'
    je .subtract

    mov rax, r13
    ret

.add:
    inc rbx
    call skip_space
    call parse_term
    add r13, rax
    jmp .loop

.subtract:
    inc rbx
    call skip_space
    call parse_term
    sub r13, rax
    jmp .loop


parse_operator:
    mov al, [rbx]

    cmp al, '+'
    je .plus

    cmp al, '-'
    je .minus

    cmp al, '*'
    je .multiply

    cmp al, '/'
    je .divide

    mov rax, 0
    ret

.plus:
    mov rax, '+'
    inc rbx
    ret

.minus:
    mov rax, '-'
    inc rbx
    ret

.multiply:
    mov rax, '*'
    inc rbx
    ret

.divide:
    mov rax, '/'
    inc rbx
    ret

skip_space:
    mov al, [rbx]

    cmp al, ' '
    jne .done

    inc rbx
    jmp skip_space

.done:
    ret

evaluate:
    cmp r11, '+'
    je .add

    cmp r11, '-'
    je .minus

    cmp r11, '*'
    je .multiply

    cmp r11, '/'
    je .divide

    ret

.add:
    add r12, rax
    ret

.minus:
    sub r12, rax
    ret

.multiply:
    imul r12, rax
    ret

.divide:
    xor rdx, rdx
    mov rcx, rax
    mov rax, r12
    div rcx
    mov r12, rax
    ret

print_number:
    mov rax, r12
    mov rbx, buffer
    add rbx, 32

    xor rcx, rcx
    mov r8, 10

.convert:
    xor rdx, rdx
    div r8

    add dl, '0'
    dec rbx
    mov [rbx], dl

    inc rcx

    cmp rax, 0
    jne .convert

.print:
    mov rdx, rcx
    mov rsi, rbx

    mov rax, 1
    mov rdi, 1
    syscall

    ret


print_char:
      push rdi
      mov rax, 1
      mov rdi, 1
      mov rsi, rbx
      mov rdx, 1
      syscall
      pop rdi
      ret


done:

    mov rax, 60
    xor rdi, rdi
    syscall
