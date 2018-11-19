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

extern engine.run

global game
game:
  ; Initialize game

  CALL video.clear, BG.BLACK

  ; Calibrate the timing
  call calibrate

  ; Game main loop
  game.loop:
    .input:
      call scan
      mov [input], al

    ; Main loop.

    engine.run

    jmp game.loop
