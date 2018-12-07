%ifndef STACK_MAC
%define STACK_MAC

%macro FUNC.START 0
    push ebp
    mov ebp, esp
%endmacro

%macro FUNC.END 0
    mov esp, ebp
    pop ebp
    ret
%endmacro

%macro CALL 2-*
    PARAMS.PUSH %{2: -1}
    call %1
    add esp, (%0 - 1) * 4
%endmacro

%macro PARAMS.PUSH 1-*
    %rep %0
        %rotate -1
        push dword %1
    %endrep
%endmacro

%define PARAM(i) ebp + 8 + i * 4

%define LOCAL(i) ebp - 4 - i * 4

%define RESERVE(n) sub esp, n * 4

%endif ; STACK_MAC