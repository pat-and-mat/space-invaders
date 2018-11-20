%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

section .data

main.gr times ROWS*COLS dw '.'|FG.RED|BG.BLACK
pause.gr times ROWS*COLS dw 'II'|FG.BLUE|BG.BLACK

section .text

extern video.set
extern video.refresh
extern scan

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    CALL video.set, main.gr
    call video.refresh
    CALL menu.wait_for_key, KEY.ENTER
    FUNC.END

; pause()
; Shows a pause menu in the screen
global menu.pause
menu.pause:
    FUNC.START
    CALL video.set, pause.gr
    call video.refresh
    CALL menu.wait_for_key, KEY.ENTER
    FUNC.END

; menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
menu.wait_for_key:
    FUNC.START
    .input:
        call scan
        cmp al, [PARAM(0)]
        jne .input
    FUNC.END