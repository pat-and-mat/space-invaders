%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"
%include "hash.inc"
%include "sound.inc"
%include "utils.inc"

extern video.set
extern video.refresh
extern scan
extern delay
extern video.print
extern actual.score
extern best_scores
extern menu.add_score
extern video.clear


extern piece.gr
extern piece.gr.rows
extern piece.gr.cols
extern piece.gr.count

extern cake.gr
extern cake.gr.rows
extern cake.gr.cols
extern cake.gr.count

extern poker.gr
extern poker.gr.rows
extern poker.gr.cols
extern poker.gr.count

extern insane.gr
extern insane.gr.rows
extern insane.gr.cols
extern insane.gr.count

extern can_not.gr
extern can_not.gr.rows
extern can_not.gr.cols
extern can_not.gr.count



section .data
;0-piece of cake 1-cake 2-poker face 3-insane 4- dont try
dificult dw 2

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

piece.row.offset dw 1
piece.col.offset dw 15

cake.row.offset dw 5
cake.col.offset dw 27

poker.row.offset dw 9
poker.col.offset dw 18

insane.row.offset dw 14
insane.col.offset dw 23

can_not.row.offset dw 19
can_not.col.offset dw 10

section .bss
debug_timer resd 2

section .text
global chose_dificult
chose_dificult:
    FUNC.START
    
    CALL video.clear, BG.BLACK
    paint:
    cmp word [dificult], 0
    jne no0
    CALL paint_piece_gr, FG.MAGENTA|BG.BLACK
    CALL paint_cake_gr, FG.GREEN|BG.BLACK
    CALL paint_poker_gr, FG.GREEN|BG.BLACK
    CALL paint_insane_gr, FG.GREEN|BG.BLACK
    CALL paint_can_not_gr, FG.GREEN|BG.BLACK
    jmp input_key
    no0:

    cmp word [dificult], 1
    jne no1
    CALL paint_piece_gr, FG.GREEN|BG.BLACK
    CALL paint_cake_gr, FG.MAGENTA|BG.BLACK
    CALL paint_poker_gr, FG.GREEN|BG.BLACK
    CALL paint_insane_gr, FG.GREEN|BG.BLACK
    CALL paint_can_not_gr, FG.GREEN|BG.BLACK
    jmp input_key
    no1:

    cmp word [dificult], 2
    jne no2
    CALL paint_piece_gr, FG.GREEN|BG.BLACK
    CALL paint_cake_gr, FG.GREEN|BG.BLACK
    CALL paint_poker_gr, FG.MAGENTA|BG.BLACK
    CALL paint_insane_gr, FG.GREEN|BG.BLACK
    CALL paint_can_not_gr, FG.GREEN|BG.BLACK
    jmp input_key
    no2:

    cmp word [dificult], 3
    jne no3
    CALL paint_piece_gr, FG.GREEN|BG.BLACK
    CALL paint_cake_gr, FG.GREEN|BG.BLACK
    CALL paint_poker_gr, FG.GREEN|BG.BLACK
    CALL paint_insane_gr, FG.MAGENTA|BG.BLACK
    CALL paint_can_not_gr, FG.GREEN|BG.BLACK
    jmp input_key
    no3:

    cmp word [dificult], 4
    jne no4
    CALL paint_piece_gr, FG.GREEN|BG.BLACK
    CALL paint_cake_gr, FG.GREEN|BG.BLACK
    CALL paint_poker_gr, FG.GREEN|BG.BLACK
    CALL paint_insane_gr, FG.GREEN|BG.BLACK
    CALL paint_can_not_gr, FG.MAGENTA|BG.BLACK
    jmp input_key
    no4:

    input_key:
    call video.refresh
    call scan

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
    je paint
    dec word [dificult]
    ;update pointer
    jmp paint

    down:
    cmp word [dificult], 4
    je paint
    inc word [dificult]
    ;update pointer
    jmp paint

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
    jmp end

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
    jmp end

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
    jmp end

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
    jmp end

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
    jmp end



paint_piece_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .piece.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [piece.gr.count]
        jnl .piece.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [piece.row.offset]
        add ax, [piece.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [piece.col.offset]
        add ax, [piece.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [piece.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .piece.while
    .piece.while.end:
    FUNC.END

paint_cake_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .cake.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [cake.gr.count]
        jnl .cake.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [cake.row.offset]
        add ax, [cake.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [cake.col.offset]
        add ax, [cake.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [cake.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .cake.while
    .cake.while.end:
    FUNC.END

    paint_poker_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .poker.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [poker.gr.count]
        jnl .poker.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [poker.row.offset]
        add ax, [poker.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [poker.col.offset]
        add ax, [poker.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [poker.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .poker.while
    .poker.while.end:
    FUNC.END

paint_insane_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .insane.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [insane.gr.count]
        jnl .insane.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [insane.row.offset]
        add ax, [insane.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [insane.col.offset]
        add ax, [insane.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [insane.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .insane.while
    .insane.while.end:
    FUNC.END

    paint_can_not_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .can_not.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [can_not.gr.count]
        jnl .can_not.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [can_not.row.offset]
        add ax, [can_not.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [can_not.col.offset]
        add ax, [can_not.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [can_not.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .can_not.while
    .can_not.while.end:
    FUNC.END

