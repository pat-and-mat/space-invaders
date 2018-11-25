%ifndef UTILS_MAC
%define UTILS_MAC

; OFFSET(dword row, dword column)
%macro OFFSET 2.nolist
    mov eax, COLS
    mul word %1
    add eax, %2
    shl eax, 1
%endmacro

%endif ; UTILS_MAC
