; Defines
    CLOSE               EQU 6
    OPEN                EQU 5
    WRITE               EQU 4
    READ                EQU 3
    EXIT                EQU 1
    STDOUT              EQU 1
    STDERR              EQU 2
    STDIN               EQU 0


section .data
    space db ' '
    newline db 10
    input db 0
    infile dd STDIN
    outfile dd STDOUT

section .bss
    ; Reserve space for buffer, assuming a maximum argument length of 1024
    buffer resb 1024

section .text
    global _start
    global system_call
    extern strlen
    extern main

_start:
    pop    ecx             ; ecx = argc
    mov    esi, esp        ; esi = argv
    mov    eax, ecx        ; put the number of arguments into eax
    shl    eax, 2          ; compute the size of argv in bytes
    add    eax, esi        ; add the size to the address of argv 
    add    eax, 4          ; skip NULL at the end of argv
    push   eax             ; char *envp[]
    push   esi             ; char* argv[]
    push   ecx             ; int argc

    call   main            ; int main(int argc, char *argv[], char *envp[])

    mov    ebx, eax
    mov    eax, EXIT
    int    0x80


system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

    
main:
    push    ebp             ; Save caller state
    mov     ebp, esp
    mov     edi, 0
    call    print_args_loop

    ; Task 1.A: Debug printout of command line arguments
print_args_loop:
    
    cmp    ecx, 0
    jz     done_printing_args
    push   ecx

    mov    ecx, [esi + edi * 4] ; get current argument pointer
    call   change_IO
    push   ecx
    call   strlen
    mov    edx, eax
    pop    ecx
    mov    eax, 4
    mov    ebx, 1
    int    0x80 


    ; print newline
    push    dword 1
    push    dword newline
    push    dword 1
    push    dword 4
    call system_call
    add     esp, 4*4

    inc    edi
    pop    ecx
    cmp    edi, ecx
    jz     done_printing_args
    jmp    print_args_loop

done_printing_args:

    call system_call
    add     esp, 4*4
    ; Task 1.B: Encoder from stdin to stdout
    call   encoder
    ret

encoder:
    enc_loop:
        mov    edx, 1       ; length of bytes to read
        mov    eax, READ    ; read
        mov    ebx, [infile] ; from infile
        mov    ecx, input   ; pointer to the buffer
        int    0x80         ; system call
        cmp    eax, 0
        jle    end_enc      ; exit loop if read returns 0 or negative

        mov    al, [input]  ; get the character
        cmp    al, 'A'
        jb     no_encode    ; if character < 'A', no encoding
        cmp    al, 'z'
        ja     no_encode    ; if character > 'z', no encoding

        inc    al           ; encode by adding 1
        mov    [input], al  ; store back encoded character

    no_encode:
        mov    edx, 1       ; length of the character
        mov    eax, WRITE 
        mov    ebx, [outfile] ; to outfile
        mov    ecx, input   ; pointer to the character
        int    0x80         ; system call
        jmp    enc_loop

    end_enc:
        ret

; Task 1.C: Support for -i and -o arguments
change_IO:
    cmp    word [ecx], '-'+(256*'i') ; equivalently "-i"
    jz     change_input
    cmp    word [ecx], '-'+(256*'o') ; equivalently "-o"
    jz     change_output
    ret

change_output:
    push ecx
    add ecx, 2
    mov eax, 8
    mov ebx, ecx
    mov ecx, 0777
    int 0x80
    mov [outfile], eax
    pop ecx
    ret

change_input:
    push ecx
    add ecx, 2
    mov eax, 5
    mov ebx, ecx
    mov ecx, 0
    int 0x80
    mov [infile], eax
    pop ecx
    ret