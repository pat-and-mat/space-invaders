%include "video.inc"
%include "keyboard.inc"
%include "stack.inc"

global input
section .bss

input resb 1

section .text

extern video.clear
extern scan
extern calibrate
extern menu.main
extern menu.loading
extern menu.pause
extern engine.run
extern engine.start

global game
game:
  ; Initialize game

  call menu.main

  ; Calibrate the timing
  call menu.loading
  call calibrate
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
    .continue:
      call engine.run

    jmp game.loop
