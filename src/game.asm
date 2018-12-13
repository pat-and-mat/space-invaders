%include "video.inc"
%include "keyboard.inc"
%include "stack.inc"

global input
section .bss

input resb 1
lose.timer resd 2

section .text

extern video.clear
extern scan
extern calibrate
extern menu.main
extern menu.loading
extern menu.pause
extern engine.run
extern engine.start
extern sound_player_die.update
extern delay
extern player.lives
extern player2.lives
extern beep.off
extern menu.lose
extern bonus_lives.init

extern player_on
extern player2_on
extern ai.lives

global game
game:
  ; Initialize game

  call menu.main

  ; Calibrate the timing
  call menu.loading
  call calibrate

  game.start:
    call engine.start

  ; Game main loop
  game.loop:
    .input:
      call scan
      mov [input], al

    ; Main loop.
    cmp byte [input], KEY.ENTER
    jne .continue

    call menu.pause
    cmp eax, 1 ; back to main menu
    je .goto_main_menu
    cmp eax, 2 ; reset
    je .reset_game
    
    .continue:
      call engine.run

    cmp word [player.lives], 0
    jne game.loop

    cmp word [player2.lives], 0
    jne game.loop

    cmp word [ai.lives], 0
    jne game.loop
    
    .play_dead_sound:
        call sound_player_die.update   ;freeze the screen 1500ms and make lose sound
        CALL delay, lose.timer, 1500
        cmp eax, 0
        je .play_dead_sound
        call beep.off
        
    call menu.lose
    cmp eax, 1 ; back to main menu
    je .goto_main_menu
    cmp eax, 2 ; reset
    je .reset_game

    jmp game.loop

    .goto_main_menu:
      call menu.main

    .reset_game:
      jmp game.start
