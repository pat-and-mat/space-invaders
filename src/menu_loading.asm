%include "video.inc"
%include "stack.inc"
%include "keyboard.inc"

extern video.refresh
extern video.print
extern video.clear

extern loading.gr
extern loading.gr.rows
extern loading.gr.cols
extern loading.gr.count

section .data

loading.row.offset dw 0
loading.col.offset dw 0

section .text

global menu.loading
menu.loading:
    FUNC.START
    CALL video.clear, BG.BLACK
    call paint_loading_gr
    call video.refresh
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
