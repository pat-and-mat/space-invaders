%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

section .data

main.gr times ROWS*COLS dw '.'|FG.RED|BG.BLACK
pause.gr times ROWS*COLS dw 'II'|FG.BLUE|BG.BLACK

section .text

extern video.set_buffer
extern scan

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    CALL video.set_buffer, main.gr
    CALL menu.wait_for_key, KEY.ENTER
    FUNC.END

; pause()
; Shows a pause menu in the screen
global menu.pause
menu.pause:
    FUNC.START
    CALL video.set_buffer, pause.gr
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