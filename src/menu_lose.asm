%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

extern video.set
extern video.refresh
extern scan
extern delay
extern video.print
extern actual.score
extern best_scores
extern menu.add_score
extern video.clear


extern loser.gr
extern loser.gr.rows
extern loser.gr.cols
extern loser.gr.count

extern main_menu.gr
extern main_menu.gr.rows
extern main_menu.gr.cols
extern main_menu.gr.count

extern reset.gr
extern reset.gr.rows
extern reset.gr.cols
extern reset.gr.count

section .data

loser.row.offset dw 3
loser.col.offset dw 5

main_menu.row.offset dw 9
main_menu.col.offset dw 17

reset.row.offset dw 15
reset.col.offset dw 27

pointer_position db 0           

section .text

; main_menu()
; Displays lose menu in the screen
global menu.lose
menu.lose:
    FUNC.START   
    
    CALL loser_menu.wait_for_key, KEY.ENTER
    ;in dependence of the actual value of pointer_position, call reset or main_menu_menu
    cmp byte [pointer_position], 0
    je reset
    cmp byte [pointer_position], 1
    je main_menu
    loser.end:
    FUNC.END

    reset:
    CALL menu.add_score, [actual.score]
    mov dword [actual.score], 0
    mov eax, 2
    jmp loser.end

    main_menu:
    mov dword [best_scores], 0
    mov dword [best_scores + 4], 0
    mov dword [best_scores + 8], 0
    mov dword [best_scores + 12], 0
    mov dword [best_scores + 16], 0
    mov dword [best_scores + 20], 0
    mov eax, 1
    jmp loser.end

; loser_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
loser_menu.wait_for_key:
    FUNC.START
    RESERVE(1)
    input:
        CALL video.clear, BG.BLACK
        call paint_loser_gr
        cmp byte [pointer_position], 1
        je touch_reset
        CALL paint_main_menu_gr, FG.MAGENTA|BG.GRAY
        CALL paint_reset_gr, FG.MAGENTA|BG.BLACK
        jmp continue

        touch_reset:
        CALL paint_main_menu_gr, FG.MAGENTA|BG.BLACK
        CALL paint_reset_gr, FG.MAGENTA|BG.GRAY
        jmp continue
    
        continue:
        call video.refresh

        xor ecx, ecx
        mov cl, byte [pointer_position]        

        call scan

        cmp al, KEY.UP
        je loser_up
        cmp al, KEY.DOWN
        je loser_down

        loser_continue:
        cmp al, [PARAM(0)]
        jne input
    FUNC.END

    loser_up: ;move to reset
    cmp byte [pointer_position], 0
    je loser_continue
    sub byte [pointer_position], 1
    jmp loser_continue

    loser_down: ;move to main_menu menu
    cmp byte [pointer_position], 1
    je loser_continue
    add byte [pointer_position], 1
    jmp loser_continue

    paint_loser_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .loser.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [loser.gr.count]
        jnl .loser.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [loser.row.offset]
        add ax, [loser.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [loser.col.offset]
        add ax, [loser.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [main_menu.gr + ecx]
        mov [LOCAL(3)], eax
        or dword [LOCAL(3)], FG.RED | BG.BLACK

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .loser.while
    .loser.while.end:
    FUNC.END

    ;paint_main_menu_gr(FG.color|BG.color)
    paint_main_menu_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .main_menu.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [main_menu.gr.count]
        jnl .main_menu.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [main_menu.row.offset]
        add ax, [main_menu.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [main_menu.col.offset]
        add ax, [main_menu.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [main_menu.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .main_menu.while
    .main_menu.while.end:
    FUNC.END

    ;paint_reset_gr(FG.color|BG.color)
    paint_reset_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .reset.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [reset.gr.count]
        jnl .reset.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [reset.row.offset]
        add ax, [reset.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [reset.col.offset]
        add ax, [reset.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [main_menu.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .reset.while
    .reset.while.end:
    FUNC.END