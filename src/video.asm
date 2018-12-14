%include "video.inc"
%include "stack.inc"
%include "utils.inc"

extern delay

; Frame buffer location
%define FBUFFER 0xB8000

section .data

screen times ROWS*COLS dw BG.BLACK

section .text

; video.clear(dword char-attrs)
; Clear the screen by filling it with char and attributes.
global video.clear
video.clear:
    FUNC.START
    mov eax, [PARAM(0)] ; char, attrs
    mov edi, screen
    mov ecx, COLS * ROWS
    cld
    rep stosw
    FUNC.END

; video.clear_rect(dword char-attrs, dword r, dword c, dword rows, dword cols)
; Fill the screen with the given values
global video.clear_rect
video.clear_rect:
    FUNC.START
    mov edi, screen
    OFFSET [PARAM(1)], [PARAM(2)]
    shl eax, 1
    add edi, eax

    mov eax, [PARAM(0)]    
    mov ecx, [PARAM(3)] ; rows
    cld
    .rows_lp:
        push ecx
        mov ecx, [PARAM(4)]
        rep stosw
        pop ecx
        
        add edi, 2 * COLS
        sub edi, [PARAM(4)]
        sub edi, [PARAM(4)]
        loop .rows_lp
    FUNC.END

; video.set(dword *screen)
; Fill screen with the given values
global video.set
video.set:
    FUNC.START
    mov esi, [PARAM(0)]
    mov edi, screen
    mov ecx, ROWS * COLS
    cld
    rep movsw
    FUNC.END

; video.set_rect(dword *rect, dword r, dword c, dword rows, dword cols)
; Fill the specified rectangle with the given values
global video.set_rect
video.set_rect:
    FUNC.START
    mov esi, [PARAM(0)]
    mov edi, screen

    OFFSET [PARAM(1)], [PARAM(2)]
    shl eax, 1
    add edi, eax
    
    mov ecx, [PARAM(3)] ; rows
    cld
    .rows_lp:
        push ecx
        mov ecx, [PARAM(4)]
        rep movsw
        pop ecx
        
        sub edi, [PARAM(4)]
        sub edi, [PARAM(4)]
        add edi, 2 * COLS
        loop .rows_lp
    FUNC.END

; video.print(dword chr-attrs, dword r, dword c)
global video.print
video.print:
    FUNC.START
    OFFSET [PARAM(1)], [PARAM(2)]
    shl eax, 1
    mov ebx, [PARAM(0)]
    mov [screen + eax], bx
    FUNC.END

; video.refresh()
global video.refresh
video.refresh:
    FUNC.START
    mov esi, screen
    mov edi, FBUFFER
    mov ecx, ROWS * COLS
    cld
    rep movsw
    FUNC.END


; video.print_number(dword number, dword last_digit_row, dword last_digit_col)
global video.print_number
video.print_number:
    FUNC.START
    mov eax, dword [PARAM(0)]

    mov ecx, dword [PARAM(1)]  
    while2:
    xor edx, edx
    mov bx, 10
    div bx

    add dx, 48
    or edx, FG.RED|BG.BLACK

    push eax
    push ecx
    CALL video.print, edx, [PARAM(2)], ecx
    pop ecx
    pop eax

    dec ecx        
    cmp eax, 0
    je end.while2
    jmp while2  
    end.while2:

    FUNC.END
