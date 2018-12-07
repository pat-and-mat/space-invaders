%include "video.inc"
%include "stack.inc"
%include "utils.inc"
%include "sound.inc"

extern delay

section .data

;the sound's bytes
;if one off then is 1, the sound is on
music db 0
shoot db 0
blue_enemy_die db 0
yellow_enemy_die db 0
red_enemy_die db 0
player_die db 0

shoot.freq dw 0200000, 0003000, 0300000
shoot.count dd 0

section .bss

;timers for the sounds
music.timer resd 2
shoot.timer resd 2
player_die.timer resd 2
blue_enemy_die.timer resd 2
red_enemy_die.timer resd 2
yellow_enemy_die.timer resd 2

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
; beep.off()
global beep.off
beep.off:
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

;here is where all the sounds are managed
;sound.update()
global sound.update
sound.update:
    FUNC.START

    ;each sound will be emited only if their sound byte is 1

    cmp byte [music], 0  
    je music.continue
    call music.update
    music.continue:

    cmp byte [shoot], 0     ;player's shoots sounds
    je shoot.continue
    call sound_shoot.update
    shoot.continue:

    ;each enemy, and the player make diferent sounds when they dies
    cmp byte [blue_enemy_die], 0
    je blue_enemy_die.continue
    call sound_blue_enemy_die.update
    blue_enemy_die.continue:

    cmp byte [red_enemy_die], 0
    je red_enemy_die.continue
    call sound_red_enemy_die.update
    red_enemy_die.continue:

    cmp byte [yellow_enemy_die], 0
    je yellow_enemy_die.continue
    call sound_yellow_enemy_die.update
    yellow_enemy_die.continue:

    cmp byte [player_die], 0
    je player_die.continue
    call sound_player_die.update
    player_die.continue:

    FUNC.END


;those are the global methods used to play the sounds, each one put on the byte off thier sound
;and reset their timer

global play_shoot
play_shoot:
    FUNC.START
    mov dword [shoot.timer], 0
    mov byte [shoot], 1
    FUNC.END

global play_player_die
play_player_die:
    FUNC.START
    mov dword [player_die.timer], 0
    mov byte [player_die], 1
    FUNC.END

global play_blue_enemy_die
play_blue_enemy_die:
    FUNC.START
    mov dword [blue_enemy_die.timer], 0
    mov byte [blue_enemy_die], 1
    FUNC.END

global play_red_enemy_die
play_red_enemy_die:
    FUNC.START
    mov dword [red_enemy_die.timer], 0
    mov byte [red_enemy_die], 1
    FUNC.END

global play_yellow_enemy_die
play_yellow_enemy_die:
    FUNC.START
    mov dword [yellow_enemy_die.timer], 0
    mov byte [yellow_enemy_die], 1
    FUNC.END




;those are the methods used to emit the sound in case off a sound byte is on

sound_shoot.update:
    FUNC.START
 
    CALL delay, shoot.timer, 50
    cmp eax, 0
    je shoot_continue
    add dword [shoot.count], 2
    cmp dword [shoot.count], 6
    je shoot.silence
    shoot_continue:
    mov eax, dword [shoot.count]
    CALL beep.set, word [shoot.freq + eax]      
    call beep.on
    jmp shoot.end

    shoot.silence:
    call beep.off
    mov byte [shoot], 0
    mov dword [shoot.count], 0

    shoot.end:
    FUNC.END

global sound_player_die.update
sound_player_die.update:
    FUNC.START
    CALL delay, player_die.timer, 1500
    cmp eax, 0
    jne player_die.silence
    CALL beep.set, 020000
    call beep.on
    jmp player_die.end

    player_die.silence:
    call beep.off
    mov byte [player_die], 0

    player_die.end:
    FUNC.END

sound_blue_enemy_die.update:
    FUNC.START
    CALL delay, blue_enemy_die.timer, 150
    cmp eax, 0
    jne blue_enemy_die.silence
    CALL beep.set, 120000
    call beep.on
    jmp blue_enemy_die.end

    blue_enemy_die.silence:
    call beep.off
    mov byte[blue_enemy_die], 0

    blue_enemy_die.end:
    FUNC.END

sound_red_enemy_die.update:
    FUNC.START
    CALL delay, red_enemy_die.timer, 150
    cmp eax, 0
    jne red_enemy_die.silence
    CALL beep.set, 400000
    call beep.on
    jmp red_enemy_die.end

    red_enemy_die.silence:
    call beep.off
    mov byte[red_enemy_die], 0

    red_enemy_die.end:
    FUNC.END

sound_yellow_enemy_die.update:
    FUNC.START
    CALL delay, yellow_enemy_die.timer, 150
    cmp eax, 0
    jne yellow_enemy_die.silence
    CALL beep.set, 140000
    call beep.on
    jmp yellow_enemy_die.end

    yellow_enemy_die.silence:
    call beep.off
    mov byte[yellow_enemy_die], 0

    yellow_enemy_die.end:
    FUNC.END


; play the music
;music.update()
global music.update
music.update:
    FUNC.START
    
    FUNC.END