%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "sound.inc"

extern delay

section .bss

global sound.timer
sound.timer resd 2

section .text

; play the seted sound
; beep.on()
global beep.on
beep.on:
    FUNC.START
    push ax
    in   al, 061H
    or   al, 03H
    out  061H, al
    pop  ax
    FUNC.END

; stop the sound sound
; beep.of()
global beep.of
beep.of:
    FUNC.START
    push ax
    in   al, 97
    and  al, 0FCH
    out  97, al
    pop  ax    
    FUNC.END    

;set a frequency to play
;beep.set(dword frequency)
global beep.set
beep.set:
    FUNC.START
    push ax
    mov  cx, [PARAM(0)]
    mov  al, 182
    out  043H, al     ; acceso a los registros del temporizador
    mov  al  , cl
    out  042H, al    ; enviamos byte inferior
    mov  al  , ch
    out  042H, al    ; enviamos byte superior
    pop   ax    
    FUNC.END


global sound.update
sound.update:
    FUNC.START

    CALL delay, sound.timer, 150
    cmp eax, 0
    je continue
    call beep.of
    continue:

    FUNC.END