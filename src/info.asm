%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"

extern video.print
extern lives

section .data

global actual.score
actual.score dd 0

section .text
;paint the info in the top of the screen
;info.paint()
global info.paint
info.paint:
    FUNC.START

    mov ecx, 0
    while:
    CALL video.print, ''|FG.BLACK|BG.GREEN, 0, ecx
    inc ecx
    cmp ecx, 80
    jne while


    CALL video.print, 'L'|FG.BLACK|BG.GREEN, 0, 0 ;paint word lives
    CALL video.print, 'I'|FG.BLACK|BG.GREEN, 0, 1
    CALL video.print, 'V'|FG.BLACK|BG.GREEN, 0, 2
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 3
    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 4
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 5

    xor eax, eax
    mov ax, word [lives]

    mov ecx, 8  ;paint las character in col 8
    ;paint the lives
    while1:
    xor edx, edx
    mov bx, 10
    div bx

    add dx, 48
    or edx, FG.RED|BG.GREEN

    push eax
    push ecx
    CALL video.print, edx, 0, ecx
    pop ecx
    pop eax

    dec ecx        
    cmp eax, 0
    je end.while1
    jmp while1   

    end.while1:

    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 65 ;paint word score
    CALL video.print, 'C'|FG.BLACK|BG.GREEN, 0, 66
    CALL video.print, 'O'|FG.BLACK|BG.GREEN, 0, 67
    CALL video.print, 'R'|FG.BLACK|BG.GREEN, 0, 68
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 69
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 70

    mov eax, dword [actual.score]

    mov ecx, 79  ;paint last character in col 79
    ;paint the score
    while2:
    xor edx, edx
    mov bx, 10
    div bx

    add dx, 48
    or edx, FG.RED|BG.GREEN

    push eax
    push ecx
    CALL video.print, edx, 0, ecx
    pop ecx
    pop eax

    dec ecx        
    cmp eax, 0
    je end.while2
    jmp while2  
    end.while2:

    FUNC.END