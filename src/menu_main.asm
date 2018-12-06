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

extern main.gr
extern main.gr.rows
extern main.gr.cols
extern main.gr.count

extern loading.gr
extern loading.gr.rows
extern loading.gr.cols
extern loading.gr.count

section .data

main.row.offset dw 0
main.col.offset dw 0

loading.row.offset dw 0
loading.col.offset dw 0

section .text

; main()
; Displays main menu in the screen
global menu.main
menu.main:
    FUNC.START
    call paint_main_gr
    call video.refresh
    CALL main_menu.wait_for_key, KEY.ENTER
    FUNC.END

global menu.loading
menu.loading:
    FUNC.START
    call paint_loading_gr
    call video.refresh
    FUNC.END

paint_main_gr:
    FUNC.START
    RESERVE(3)

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

        push ecx
        CALL video.print, [main.gr + ecx], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .main.while
    .main.while.end:
    FUNC.END

paint_loading_gr:
    FUNC.START
    RESERVE(3)

    mov dword [LOCAL(0)], 0    
    .loading.while:
        mov ecx, [LOCAL(0)]

        cmp ecx, [loading.gr.count]
        jnl .loading.while.end

        shl ecx, 1
        
        xor eax, eax
        mov ax, [loading.row.offset]
        add ax, [loading.gr.rows + ecx]
        mov [LOCAL(1)], eax

        xor eax, eax
        mov ax, [loading.col.offset]
        add ax, [loading.gr.cols + ecx]
        mov [LOCAL(2)], eax

        push ecx
        CALL video.print, [loading.gr + ecx], [LOCAL(1)], [LOCAL(2)]
        pop ecx

        inc dword [LOCAL(0)]
        jmp .loading.while
    .loading.while.end:
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