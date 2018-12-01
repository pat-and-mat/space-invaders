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
extern engine.reset

section .data

main.gr times ROWS*COLS dw '.'|FG.RED|BG.BLACK
pause.gr times 17 * 25 dw '.'|FG.BLACK|BG.BRIGHT
scores.gr times 17 * 25 dw '.'|FG.BLACK|BG.BRIGHT

pointer_position db 0
pointer dd 6, 11, 16
string_pointer  dw " "|FG.GREEN|BG.BRIGHT, "/"|FG.GREEN|BG.BRIGHT, " "|FG.GREEN|BG.BRIGHT,\
                   "("|FG.GREEN|BG.BRIGHT, "="|FG.GREEN|BG.BRIGHT, "="|FG.GREEN|BG.BRIGHT,\
                   " "|FG.GREEN|BG.BRIGHT, "\"|FG.GREEN|BG.BRIGHT, " "|FG.GREEN|BG.BRIGHT, 0

string_clean  dw   '.'|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT,\
                   "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT,\
                   "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, 0                


;words used in the pause menu
string_continue dw "C"|FG.RED|BG.BLACK, "o"|FG.RED|BG.BLACK,\
                   "n"|FG.RED|BG.BLACK, "t"|FG.RED|BG.BLACK,\
                   "i"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                   "u"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK, 0

string_reset dw    "R"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "s"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "t"|FG.RED|BG.BLACK, 0

string_main_menu dw  "m"|FG.RED|BG.BLACK, "a"|FG.RED|BG.BLACK,\
                     "i"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                     " "|FG.RED|BG.BLACK, "m"|FG.RED|BG.BLACK,\
                     "e"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                     "u"|FG.RED|BG.BLACK, 0

string_score1 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "1"|FG.RED|BG.BLACK, 0

string_score2 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "2"|FG.RED|BG.BLACK, 0

string_score3 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "3"|FG.RED|BG.BLACK, 0

string_score4 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "4"|FG.RED|BG.BLACK, 0

string_score5 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "5"|FG.RED|BG.BLACK, 0

string_score6 dw   "s"|FG.RED|BG.BLACK, "c"|FG.RED|BG.BLACK,\
                   "o"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                   "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                   "6"|FG.RED|BG.BLACK, 0                                                                                                                                                        

section .bss
best_scores resd 5

timer resd 2


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

; pause()
; Shows a pause menu in the screen
global menu.pause
menu.pause:
    FUNC.START
    CALL video.set_rect, pause.gr, 4, 47, 17, 25
    CALL video.set_rect, scores.gr, 4, 7, 17, 25

    CALL video.set_rect, string_continue, 7, 51, 1, 8
    CALL video.set_rect, string_reset, 12, 51, 1, 5
    CALL video.set_rect, string_main_menu, 17, 51, 1, 9
    CALL video.set_rect, string_score1, 7, 9, 1, 7
    CALL video.set_rect, string_score2, 9, 9, 1, 7
    CALL video.set_rect, string_score3, 11, 9, 1, 7
    CALL video.set_rect, string_score4, 13, 9, 1, 7
    CALL video.set_rect, string_score5, 15, 9, 1, 7
    CALL video.set_rect, string_score6, 17, 9, 1, 7    

    call video.refresh
    CALL pause_menu.wait_for_key, KEY.ENTER
    cmp byte [pointer_position], 4
    je reset
    cmp byte [pointer_position], 8
    je main
    pause.end:
    FUNC.END

    reset:
    call engine.reset
    jmp pause.end

    main:
    call engine.reset
    call menu.main
    jmp pause.end
    

; pause_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
pause_menu.wait_for_key:
    FUNC.START
    input:
        jmp clean
        clean_continue:
        xor ecx, ecx
        mov cl, byte [pointer_position]
        mov eax, [pointer + ecx]
        CALL video.set_rect, string_pointer, eax, 62, 3, 3
        call video.refresh

        call scan

        cmp al, KEY.UP
        je pause_up
        cmp al, KEY.DOWN
        je pause_down

        pause_continue:
        cmp al, [PARAM(0)]
        jne input
    FUNC.END

    pause_up:
    cmp byte [pointer_position], 0
    je pause_continue
    sub byte [pointer_position], 4
    jmp pause_continue

    pause_down:
    cmp byte [pointer_position], 8
    je pause_continue
    add byte [pointer_position], 4
    jmp pause_continue

    clean:
    CALL video.set_rect, string_clean, 6, 62, 3, 3
    CALL video.set_rect, string_clean, 11, 62, 3, 3
    CALL video.set_rect, string_clean, 16, 62, 3, 3
    jmp clean_continue

; main_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
main_menu.wait_for_key:
    FUNC.START
    .input:
        call scan
        cmp al, [PARAM(0)]
        jne .input
    FUNC.END