%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

extern video.set
extern video.set_rect
extern video.refresh
extern scan
extern video.print_word
extern delay
extern video.print
extern video.print_number
extern engine.reset
extern actual.score

section .data

main.gr times ROWS*COLS dw '.'|FG.RED|BG.BLACK

section .text

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    CALL video.set, main.gr
    call video.refresh
    CALL main_menu.wait_for_key, KEY.ENTER
    FUNC.END

; main_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
main_menu.wait_for_key:
    FUNC.START
    .input:
        call scan
        cmp al, [PARAM(0)]
        jne .input
    FUNC.END