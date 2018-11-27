%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "sound.inc"

extern delay

section .bss

global sound.timer
sound.timer resd 2

section .text

; El Registro 61H es del sistema y el bit0 hace que la onda del TIMER2 [0..2]
; acceda al altavoz.  Por otro lado el bit1 activa el altavoz
global beep.on
beep.on:
    FUNC.START
    push ax
    in   al, 061H
    or   al, 03H
    out  061H, al
    pop  ax
    FUNC.END

global beep.of
beep.of:
    FUNC.START
    push ax
    in   al, 97
    and  al, 0FCH
    out  97, al
    pop  ax    
    FUNC.END    

; Funcion que configura el periodo del timer
; en 55mseg -> Cargar el valor 0FFFFH
; cambiando el valor cambia la frecuencia del altavoz
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