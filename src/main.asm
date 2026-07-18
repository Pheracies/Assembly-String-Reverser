;I wrote the code, and had AI document it.
;Essentially this is a string reversal program in x86-64 assembly language. 
;It prompts the user for a string, reverses it, and then prints the reversed string.
extern printf           
extern gets_s            
extern exit
extern strlen

section .data
    greeting_message: db "Please enter a string to reverse: ", 10, 0
    format_string:    db "%s", 0
    result_message:   db "Reversed string: %s", 10, 0

section .bss
    reversal_string:  resb 100

section .text
global main
global print_section
global reverse_string
global swap_string

; --- 1. THE SWAP HELPER FUNCTION ---
; Expects: RCX = Pointer to Left Character, RDX = Pointer to Right Character
swap_string:
    push rbp
    mov rbp, rsp

    mov al, byte [rcx]          ; 1. Grab left character into AL
    mov bl, byte [rdx]          ; 2. Grab right character into BL

    mov byte [rcx], bl          ; 3. Write BL into left memory slot
    mov byte [rdx], al          ; 4. Write AL into right memory slot

    pop rbp
    ret

; --- 2. THE REVERSAL CONTROLLER ---
; Expects: RCX = Pointer to the string buffer
reverse_string:
    push rbp
    mov rbp, rsp
    sub rsp, 48                 ; Shadow space + extra safety buffer for local vars

    call strlen                 ; RAX now holds the length of the string
    
    cmp rax, 1                  ; If string length is 0 or 1, there's nothing to reverse
    jle .done

    ; Set up our start and end tracking registers
    lea rsi, [rel reversal_string]      ; RSI = Start pointer
    lea rdi, [rel reversal_string]      ; RDI = Start pointer...
    add rdi, rax                        ; ...plus length
    dec rdi                             ; RDI = End pointer (Length - 1)

.loop_top:
    cmp rsi, rdi                ; Have the pointers crossed or met in the middle?
    jae .done                   ; If Start >= End, we are finished!

    ; Set up arguments for our swap function
    mov rcx, rsi                ; Argument 1: Left address pointer
    mov rdx, rdi                ; Argument 2: Right address pointer
    call swap_string

    inc rsi                     ; Move Start pointer right by 1 byte
    dec rdi                     ; Move End pointer left by 1 byte
    jmp .loop_top               ; Repeat loop

.done:
    add rsp, 48
    pop rbp
    ret

; --- 3. THE PRINT HELPER ---
print_section:
    push rbp
    mov rbp, rsp
    sub rsp, 32                 

    lea rcx, [rel format_string]    
    lea rdx, [rel greeting_message] 
    call printf

    add rsp, 32                 
    pop rbp
    ret                         

; --- 4. THE MAIN ENTRY ROUTINE ---
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                 

    ; A. Print the initial prompt
    call print_section

    ; B. Read the user input string into our BSS buffer
    lea rcx, [rel reversal_string]  ; Pass our buffer address as Arg 1
    mov rdx, 100                    ; Pass the buffer size as Arg 2
    call gets_s

    ; C. Call the string reversal logic
    lea rcx, [rel reversal_string]  ; Pass our buffer address as Arg 1
    call reverse_string             

    ; D. Print the final reversed string result to verify it works!
    lea rcx, [rel result_message]
    lea rdx, [rel reversal_string]
    call printf

    ; E. Clean exit
    xor rcx, rcx
    call exit