%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"
%include "sound.inc"
%include "utils.inc"

extern video.clear
extern scan

section .bss

section .data
;0-piece of cake 1-cake 2-poker face 3-insane 4- dont try
dificult dw 2
;pointer dd

global colors
colors dd 0, 0, 1, 1, 2, 2, 3, 0, 0, 0, 0, 0
global colors_count
colors_count dd 7
global generate_time
generate_time dd 1500
global generate_amount
generate_amount dd 6
global bonus_time
bonus_time dd 5000
global boss_time
boss_time dd 30000

section .text
global chose_dificult
chose_dificult:
    FUNC.START
    CALL video.clear, BG.BLACK
    paint:
    ;paint words
        
    call scan

    input:
    cmp al, KEY.UP
    je up
    cmp al, KEY.DOWN
    je down

    continue:
    cmp al, KEY.ENTER
    jne paint

    cmp word [dificult], 0
    je piece_of_cake
    cmp word [dificult], 1
    je cake
    cmp word [dificult], 2
    je poker_face
    cmp word [dificult], 3
    je insane
    cmp word [dificult], 4
    je dont_try
    end:
    FUNC.END

    up:
    cmp word [dificult], 0
    je continue
    dec word [dificult]
    ;update pointer
    jmp continue

    down:
    cmp word [dificult], 4
    je continue
    inc word [dificult]
    ;update pointer
    jmp continue

    piece_of_cake:
    mov dword [colors_count], 6
    mov dword [colors],      0
    mov dword [colors + 4],  0
    mov dword [colors + 8],  0
    mov dword [colors + 12], 0
    mov dword [colors + 16], 1
    mov dword [colors + 20], 1
    mov dword [generate_time], 3000
    mov dword [generate_amount], 4
    mov dword [bonus_time], 3000
    mov dword [boss_time], 60000
    jmp input

    cake:
    mov dword [colors_count], 6
    mov dword [colors],      0
    mov dword [colors + 4],  0
    mov dword [colors + 8],  1
    mov dword [colors + 12], 1
    mov dword [colors + 16], 2
    mov dword [colors + 20], 2
    mov dword [generate_time], 2000
    mov dword [generate_amount], 6
    mov dword [bonus_time], 4000
    mov dword [boss_time], 45000
    jmp input

    poker_face:
    mov dword [colors_count], 6
    mov dword [colors],      0
    mov dword [colors + 4],  0
    mov dword [colors + 8],  1
    mov dword [colors + 12], 1
    mov dword [colors + 16], 2
    mov dword [colors + 20], 2
    mov dword [colors + 24], 3
    mov dword [generate_time], 1500
    mov dword [generate_amount], 7
    mov dword [bonus_time], 8000
    mov dword [boss_time], 30000
    jmp input

    insane:
    mov dword [colors_count], 6
    mov dword [colors],      0
    mov dword [colors + 4],  0
    mov dword [colors + 8],  1
    mov dword [colors + 12], 1
    mov dword [colors + 16], 2
    mov dword [colors + 20], 2
    mov dword [colors + 24], 3
    mov dword [generate_time], 1000
    mov dword [generate_amount], 10
    mov dword [bonus_time], 12000
    mov dword [boss_time], 30000
    jmp input

    dont_try:
    mov dword [colors_count], 11
    mov dword [colors],      0
    mov dword [colors + 4],  0
    mov dword [colors + 8],  0
    mov dword [colors + 12], 1
    mov dword [colors + 16], 1
    mov dword [colors + 20], 1
    mov dword [colors + 24],  2
    mov dword [colors + 28], 2
    mov dword [colors + 32], 2
    mov dword [colors + 36], 3
    mov dword [colors + 40], 3
    mov dword [generate_time], 500
    mov dword [generate_amount], 10
    mov dword [bonus_time], 15000
    mov dword [boss_time], 30000
    jmp input
