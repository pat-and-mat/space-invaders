%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"

extern video.print
extern player.lives
extern player2.lives
extern player_on
extern player2_on

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

    ;**********************************************************************************
    ;player1
    cmp byte[player_on], 0
    je end.while1
    
    CALL video.print, 'L'|FG.BLACK|BG.GREEN, 0, 0 ;paint word player.lives
    CALL video.print, 'I'|FG.BLACK|BG.GREEN, 0, 1
    CALL video.print, 'V'|FG.BLACK|BG.GREEN, 0, 2
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 3
    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 4
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 5

    xor eax, eax
    mov ax, word [player.lives]
    add eax, 6
    mov ecx, 6  ;paint las character in col 8
    ;paint the player.lives
    while1:

    push ecx
    push eax
    CALL video.print, 3|FG.RED|BG.GREEN, 0, ecx 
    pop eax
    pop ecx

    inc ecx
    cmp ecx, eax
    jg end.while1
    jmp while1   

    end.while1:

    ;***************************************************************************************
    ;player2
    cmp byte[player2_on], 0
    je end._while1

    CALL video.print, 'L'|FG.BLACK|BG.GREEN, 0, 30 ;paint word player2.lives
    CALL video.print, 'I'|FG.BLACK|BG.GREEN, 0, 31
    CALL video.print, 'V'|FG.BLACK|BG.GREEN, 0, 32
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 33
    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 34
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 35

    xor eax, eax
    mov ax, word [player2.lives]
    add eax, 36
    mov ecx, 36  ;paint las character in col 8
    ;paint the player2.lives
    _while1:

    push ecx
    push eax
    CALL video.print, 3|FG.BLUE|BG.GREEN, 0, ecx 
    pop eax
    pop ecx

    inc ecx
    cmp ecx, eax
    jg end._while1
    jmp _while1   

    end._while1:

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