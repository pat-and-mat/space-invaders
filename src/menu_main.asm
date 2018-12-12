%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

extern chose_dificult
extern scan
extern video.print
extern video.clear
extern video.refresh

extern main.gr
extern main.gr.rows
extern main.gr.cols
extern main.gr.count

extern options.gr
extern options.gr.rows
extern options.gr.cols
extern options.gr.count

extern start.gr
extern start.gr.rows
extern start.gr.cols
extern start.gr.count

section .data

pointer_position db 0

main.row.offset dw 1
main.col.offset dw 3

start.row.offset dw 15
start.col.offset dw 5

options.row.offset dw 15
options.col.offset dw 45

section .text

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    ini:
    CALL video.clear, BG.BLACK
    call paint_main_gr
    call video.refresh
    CALL main_menu.wait_for_key, KEY.ENTER
    cmp byte [pointer_position], 0
    je main_menu_end
    call chose_dificult
    jmp ini
    main_menu_end:
    FUNC.END

paint_main_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .main.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [main.gr.count]
        jnl .main.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [main.row.offset]
        add ax, [main.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [main.col.offset]
        add ax, [main.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [main.gr + ecx]
        mov [LOCAL(3)], eax
        or dword [LOCAL(3)], FG.GREEN | BG.BLACK

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .main.while
    .main.while.end:
    FUNC.END

paint_options_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .options.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [options.gr.count]
        jnl .options.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [options.row.offset]
        add ax, [options.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [options.col.offset]
        add ax, [options.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [options.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .options.while
    .options.while.end:
    FUNC.END

paint_start_gr:
    FUNC.START
    RESERVE(4)

    mov dword [LOCAL(0)], 0    
    .start.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [start.gr.count]
        jnl .start.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [start.row.offset]
        add ax, [start.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [start.col.offset]
        add ax, [start.gr.cols + ecx]
        mov [LOCAL(2)], eax

        xor eax, eax
        mov ax, [start.gr + ecx]
        mov [LOCAL(3)], eax
        mov eax, [PARAM(0)]
        or dword [LOCAL(3)], eax

        push ecx
        CALL video.print, [LOCAL(3)], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .start.while
    .start.while.end:
    FUNC.END

; main_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
main_menu.wait_for_key:
    FUNC.START
    input:
        cmp byte [pointer_position], 1
        je touch_options
        CALL paint_start_gr, FG.MAGENTA|BG.BLACK
        CALL paint_options_gr, FG.GREEN|BG.BLACK
        jmp continue

        touch_options:
        CALL paint_start_gr, FG.GREEN|BG.BLACK
        CALL paint_options_gr, FG.MAGENTA|BG.BLACK
        jmp continue
    
        continue:
        call video.refresh

        call scan

        cmp al, KEY.RIGHT
        je right
        cmp al, KEY.LEFT
        je left
        end:
        cmp al, [PARAM(0)]
        jne input
    FUNC.END

    right:
    cmp byte [pointer_position], 1
    je end
    add byte [pointer_position], 1
    jmp end

    left:
    cmp byte [pointer_position], 0
    je end
    sub byte [pointer_position], 1
    jmp end