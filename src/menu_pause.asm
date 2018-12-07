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
extern menu.main

section .data

pause.gr times 17 * 25 dw '.'|FG.BLACK|BG.GRAY
scores.gr times 17 * 25 dw '.'|FG.BLACK|BG.GRAY

pointer_position db 0
pointer dd 7, 12, 17
string_pointer  dw "<"|FG.GREEN|BG.BLACK, "="|FG.GREEN|BG.BLACK, "="|FG.GREEN|BG.BLACK, 0 
string_clean  dw   '.'|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, "."|FG.BLACK|BG.BRIGHT, 0                


;words used in the pause menu
string_continue dw "C"|FG.RED|BG.BLACK, "o"|FG.RED|BG.BLACK,\
                   "n"|FG.RED|BG.BLACK, "t"|FG.RED|BG.BLACK,\
                   "i"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                   "u"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK, 0

string_reset dw    "R"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "s"|FG.RED|BG.BLACK, "e"|FG.RED|BG.BLACK,\
                   "t"|FG.RED|BG.BLACK, 0

string_main_menu dw  "M"|FG.RED|BG.BLACK, "a"|FG.RED|BG.BLACK,\
                     "i"|FG.RED|BG.BLACK, "n"|FG.RED|BG.BLACK,\
                     " "|FG.RED|BG.BLACK, "M"|FG.RED|BG.BLACK,\
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

global best_scores
best_scores dd 0, 0, 0, 0, 0, 0                                                                                                                                                          

section .bss
timer resd 2


section .text

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

    ;painting the best scores of the actual game
    CALL video.print_number, [best_scores], 25, 7
    CALL video.print_number, [best_scores + 4], 25, 9
    CALL video.print_number, [best_scores + 8], 25, 11
    CALL video.print_number, [best_scores + 12], 25, 13
    CALL video.print_number, [best_scores + 16], 25, 15
    CALL video.print_number, [best_scores + 20], 25, 17


    call video.refresh
    CALL pause_menu.wait_for_key, KEY.ENTER
    cmp byte [pointer_position], 4
    je reset
    cmp byte [pointer_position], 8
    je main
    pause.end:
    FUNC.END

    reset:
    CALL menu.add_score, [actual.score]
    mov dword [actual.score], 0
    call engine.start
    jmp pause.end

    main:
    mov dword [best_scores], 0
    mov dword [best_scores + 4], 0
    mov dword [best_scores + 8], 0
    mov dword [best_scores + 12], 0
    mov dword [best_scores + 16], 0
    mov dword [best_scores + 20], 0
    call engine.start
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
        CALL video.set_rect, string_pointer, eax, 62, 1, 3
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
    CALL video.set_rect, string_clean, 7, 62, 1, 3
    CALL video.set_rect, string_clean, 12, 62, 1, 3
    CALL video.set_rect, string_clean, 17, 62, 1, 3
    jmp clean_continue

; menu.add_score(dword score)
; add a score to the table if is better than any present
global menu.add_score
menu.add_score:
    FUNC.START
    mov eax, [PARAM(0)]

    cmp eax, [best_scores]
    jng no_score1

    mov edx, [best_scores + 16]
    mov dword [best_scores + 20], edx
    mov edx, [best_scores + 12]
    mov dword [best_scores + 16], edx
    mov edx, [best_scores + 8]
    mov dword [best_scores + 12], edx
    mov edx, [best_scores + 4]
    mov dword [best_scores + 8], edx
    mov edx, [best_scores]
    mov dword [best_scores + 4], edx
    mov dword [best_scores], eax
    jmp add_score_end
    no_score1:

    cmp eax, [best_scores + 4]
    jng no_score2

    mov edx, [best_scores + 16]
    mov dword [best_scores + 20], edx
    mov edx, [best_scores + 12]
    mov dword [best_scores + 16], edx
    mov edx, [best_scores + 8]
    mov dword [best_scores + 12], edx
    mov edx, [best_scores + 4]
    mov dword [best_scores + 8], edx
    mov dword [best_scores + 4], eax
    jmp add_score_end
    no_score2:

    cmp eax, [best_scores + 8]
    jng no_score3

    mov edx, [best_scores + 16]
    mov dword [best_scores + 20], edx
    mov edx, [best_scores + 12]
    mov dword [best_scores + 16], edx
    mov edx, [best_scores + 8]
    mov dword [best_scores + 12], edx
    mov dword [best_scores + 8], eax
    jmp add_score_end
    no_score3:

    cmp eax, [best_scores + 12]
    jng no_score4

    mov edx, [best_scores + 16]
    mov dword [best_scores + 20], edx
    mov edx, [best_scores + 12]
    mov dword [best_scores + 16], edx
    mov dword [best_scores + 12], eax
    jmp add_score_end
    no_score4:

    cmp eax, [best_scores + 16]
    jng no_score5

    mov edx, [best_scores + 16]
    mov dword [best_scores + 20], edx
    mov dword [best_scores + 16], eax
    jmp add_score_end
    no_score5:

    cmp eax, [best_scores + 20]
    jng no_score6

    mov dword [best_scores + 20], eax
    jmp add_score_end
    no_score6:

    add_score_end:
    FUNC.END