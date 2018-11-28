%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"

extern video.print
extern video.clear
extern delay
extern weapons.shoot
extern rand
extern lives

section .data

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


    CALL video.print, 'L'|FG.BLACK|BG.GREEN, 0, 0
    CALL video.print, 'I'|FG.BLACK|BG.GREEN, 0, 1
    CALL video.print, 'V'|FG.BLACK|BG.GREEN, 0, 2
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 3
    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 4
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 5

    mov eax, dword [lives]

    ; CALL video.print, al|FG.BLACK|BG.GREEN, 0, 7
    ; CALL video.print, ah|FG.BLACK|BG.GREEN, 0, 8

    CALL video.print, 'S'|FG.BLACK|BG.GREEN, 0, 65
    CALL video.print, 'C'|FG.BLACK|BG.GREEN, 0, 66
    CALL video.print, 'O'|FG.BLACK|BG.GREEN, 0, 67
    CALL video.print, 'R'|FG.BLACK|BG.GREEN, 0, 68
    CALL video.print, 'E'|FG.BLACK|BG.GREEN, 0, 69
    CALL video.print, ':'|FG.BLACK|BG.GREEN, 0, 70

    mov eax, dword [actual.score]

    FUNC.END