%include "video.inc"
%include "stack.inc"

; Frame buffer location
%define FBUFFER 0xB8000

; FBOFFSET(word row, word column)
%macro FBOFFSET 2.nolist
    mov eax, COLS
    mul word %1
    add eax, %2
    shl eax, 1
%endmacro

section .text

; video.clear(dword char-attrs)
; Clear the screen by filling it with char and attributes.
global video.clear
video.clear:
    FUNC.START
    mov eax, [PARAM(0)] ; char, attrs
    mov edi, FBUFFER
    mov ecx, COLS * ROWS
    cld
    rep stosw
    FUNC.END

; video.set_buffer(dword *buffer)
; Fill the screen with the given values
global video.set_buffer
video.set_buffer:
    FUNC.START
    mov esi, [PARAM(0)]
    mov edi, FBUFFER
    mov ecx, ROWS * COLS
    cld
    
    .lp:
        cmpsw
        je .cont

        sub esi, 2
        sub edi, 2
        movsw

        .cont:
            loop .lp
    FUNC.END

; video.print(dword chr-attrs, dword r, dword c)
global video.print
video.print:
    FUNC.START
    mov ebx, [PARAM(0)]
    FBOFFSET [PARAM(1)], [PARAM(2)]
    mov [FBUFFER + eax], bx
    FUNC.END

; video.putc_at(dword map, dword chr-attrs, dword r, dword c)
; for printing at the given map or canvas
global video.print_at
video.print_at:
    FUNC.START
    mov edx, [PARAM(1)]
    FBOFFSET [PARAM(2)], [PARAM(3)]
    mov ecx, [PARAM(0)]
    mov [ecx + eax], dx
    FUNC.END

