%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "sound.inc"

extern delay

section .data

music db 0

shoot db 0

enemy_blue.die db 0

enemy_yellow.die db 0

enemy_red.die db 0

player.die db 0

section .bss


end.sound.timer resd 2

music.timer1 resd 2
music.timer2 resd 2
music.timer3 resd 2
music.timer4 resd 2
music.timer5 resd 2

shoot.timer1 resd 2
shoot.timer2 resd 2

section .text

; play the seted sound
; beep.on()
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

    ; cmp byte [music], 0
    ; je music.continue
    ; call music.update
    ; music.continue:

    cmp byte [shoot], 0
    je shoot.continue
    call sound_shoot.update
    shoot.continue:

    ; cmp [sound_enemy_blue.die], 0
    ; je enemy_blue.die.continue
    ; call sound_enemy_blue.die.update
    ; enemy_blue.die.continue:

    ; cmp [sound_enemy_red.die], 0
    ; je enemy_red.die.continue
    ; call sound_enemy_red.die.update
    ; enemy_red.die.continue:

    ; cmp [sound_enemy_yellow.die], 0
    ; je enemy_yellow.die.continue
    ; call sound_enemy_yellow.die.update
    ; enemy_yellow.die.continue:

    ; cmp [player.die], 0
    ; je player.die.continue
    ; call player.die.update
    ; player.die.continue:


    FUNC.END


global play_shoot
play_shoot:
    FUNC.START
    mov dword [end.sound.timer], 0
    mov dword [shoot.timer1], 0
    mov dword [shoot.timer2], 0
    mov byte [shoot], 1
    FUNC.END

sound_shoot.update:
    FUNC.START
    ;making sound

    CALL beep.set, 010000      
    call beep.on
    shoot_countinue1:

    CALL delay, shoot.timer1, 50
    cmp eax, 0
    je shoot_end
    CALL beep.set, 004000
    call beep.on

    CALL delay, shoot.timer2, 75
    cmp eax, 0
    je shoot_end
    CALL beep.set, 002500
    call beep.on

    CALL delay, end.sound.timer, 150
    cmp eax, 0
    je shoot_end
    call beep.of

    mov byte [shoot], 0

    shoot_end:
    FUNC.END





; play the music
;music.update()
global music.update
music.update:
    FUNC.START

    call beep.on

    CALL delay, music.timer1, 900
    cmp eax, 0
    je music_end
    CALL beep.set, 005000


    CALL delay, music.timer2, 1050
    cmp eax, 0
    je music_end
    CALL beep.set, 000040

    CALL delay, music.timer3, 1200
    cmp eax, 0
    je music_end
    CALL beep.set, 000000

    CALL delay, music.timer4, 1350
    cmp eax, 0
    je music_end
    CALL beep.set, 003200

    CALL delay, music.timer5, 1500
    cmp eax, 0
    je music_end
    CALL beep.set, 005500


    CALL delay, end.sound.timer, 1750
    cmp eax, 0
    je music_end
    call beep.of

    music_end:
    FUNC.END