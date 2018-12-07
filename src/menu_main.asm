%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

extern scan
extern video.print
extern video.clear
extern video.refresh

extern main.gr
extern main.gr.rows
extern main.gr.cols
extern main.gr.count

section .data

pointer_position db 0

main.row.offset dw 1
main.col.offset dw 3

section .text

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    CALL video.clear, BG.BLACK
    call paint_main_gr
    call video.refresh
    CALL main_menu.wait_for_key, KEY.ENTER
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

; main_menu.wait_for_key(dword key)
; Waits for the user to enter the specified key
main_menu.wait_for_key:
    FUNC.START
    .input:
        call scan
        cmp al, [PARAM(0)]
        jne .input
    FUNC.END