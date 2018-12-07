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
extern engine.start
extern actual.score
extern best_scores
extern engine.reset
extern menu.main
extern menu.add_score

section .data

lose.gr times ROWS*COLS dw '.'|FG.GRAY|BG.BLACK

string_pointer1  dw "<"|FG.GREEN|BG.BLACK, "="|FG.GREEN|BG.BLACK, "="|FG.GREEN|BG.BLACK, 0
string_pointer2  dw "="|FG.GREEN|BG.BLACK, "="|FG.GREEN|BG.BLACK, ">"|FG.GREEN|BG.BLACK, 0
string_clean  dw   '.'|FG.GRAY|BG.BLACK, "."|FG.GRAY|BG.BLACK, "."|FG.GRAY|BG.BLACK, 0

string_main_menu dw  "M"|FG.RED|BG.BLACK, "a"|FG.RED|BG.BLACK,\
                     "i"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                     " "|FG.RED|BG.BLACK, "M"|FG.RED|BG.BLACK,\
                     "e"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                     "u"|FG.RED|BG.BLACK, 0

string_reset dw    "R"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "s"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "t"|FG.RED|BG.BLACK, 0

string_you_are_a_loser dw  "Y"|FG.RED|BG.BLACK, "o"|FG.RED|BG.BLACK,\
                           "u"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                           "a"|FG.RED|BG.BLACK, "r"|FG.RED|BG.BLACK,\
                           "e"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                           "a"|FG.RED|BG.BLACK, " "|FG.RED|BG.BLACK,\
                           "L"|FG.RED|BG.BLACK, "O"|FG.RED|BG.BLACK,\
                           "S"|FG.RED|BG.BLACK, "E"|FG.RED|BG.BLACK,\
                           "R"|FG.RED|BG.BLACK, 0

pointer dd 10, 15             
pointer_position db 0           

section .bss

section .text

; main()
; Displays lose menu in the screen
global menu.lose
menu.lose:
    FUNC.START
    CALL video.set, lose.gr
    
    ;paint the three words on the screen
    CALL video.set_rect, string_you_are_a_loser, 5, 33, 1, 15
    CALL video.set_rect, string_reset, 10, 38, 1, 5
    CALL video.set_rect, string_main_menu, 15, 36, 1, 9

    call video.refresh

    CALL lose_menu.wait_for_key, KEY.ENTER
    ;in dependence of the actual value of pointer_position, call reset or main_menu
    cmp byte [pointer_position], 0
    je reset
    cmp byte [pointer_position], 4
    je main
    lose.end:
    FUNC.END

    reset:
    CALL menu.add_score, [actual.score]
    mov dword [actual.score], 0
    call engine.start
    jmp lose.end

    main:
    mov dword [best_scores], 0
    mov dword [best_scores + 4], 0
    mov dword [best_scores + 8], 0
    mov dword [best_scores + 12], 0
    mov dword [best_scores + 16], 0
    mov dword [best_scores + 20], 0
    call engine.start
    call menu.main
    jmp lose.end

; lose_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
lose_menu.wait_for_key:
    FUNC.START
    RESERVE(1)
    input:
        jmp clean
        clean_continue:
        xor ecx, ecx
        mov cl, byte [pointer_position]
        mov eax, [pointer + ecx]
        mov [LOCAL(0)], eax
        ;paint the pointers in the screen
        ;their position depend of pointer_position's value
        CALL video.set_rect, string_pointer1, [LOCAL(0)], 49, 1, 3
        CALL video.set_rect, string_pointer2, [LOCAL(0)], 29, 1, 3
        call video.refresh

        call scan

        cmp al, KEY.UP
        je lose_up
        cmp al, KEY.DOWN
        je lose_down

        lose_continue:
        cmp al, [PARAM(0)]
        jne input
    FUNC.END

    lose_up: ;move to reset
    cmp byte [pointer_position], 0
    je lose_continue
    sub byte [pointer_position], 4
    jmp lose_continue

    lose_down: ;move to main menu
    cmp byte [pointer_position], 4
    je lose_continue
    add byte [pointer_position], 4
    jmp lose_continue

    clean:  ;clean the pointers
    CALL video.set_rect, string_clean, 10, 49, 1, 3
    CALL video.set_rect, string_clean, 10, 29, 1, 3
    CALL video.set_rect, string_clean, 15, 49, 1, 3
    CALL video.set_rect, string_clean, 15, 29, 1, 3
    jmp clean_continue