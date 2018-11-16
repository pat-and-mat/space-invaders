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

; video.putc(dword chr-attrs, dword r, dword c)
global video.putc
video.print:
    FUNC.START
    mov edx, [PARAM(0)]
    FBOFFSET [PARAM(1)], [PARAM(2)]
    mov [FBUFFER + eax], dx
    FUNC.END
