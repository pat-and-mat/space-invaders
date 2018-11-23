%include "stack.inc"
%include "video.inc"
%include "keyboard.inc"

;rand(dword range)
global rand
rand:
    FUNC.START

    rdtsc
    xor edx, edx
    div dword [PARAM(0)]
    mov eax, edx

    FUNC.END