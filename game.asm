.include "includes.asm"

.data
game_started: .word 0

.globl game
.text

game:
  enter

  jal init_game

_wait_first_key:
  jal draw_game
  jal display_update_and_clear

  jal wait_for_next_frame


  jal handle_input
  jal input_get_keys_held
  # start game after first key pressed
  lw t0, game_started
  beq t0, 1, _game_started

  # wait util first key pressed
  li t0, 0
  lw t1, up_pressed
  or t0, t0, t1
  lw t1, down_pressed
  or t0, t0, t1
  lw t1, left_pressed
  or t0, t0, t1
  lw t1, right_pressed
  or t0, t0, t1
  lw t1, b_pressed
  or t0, t0, t1
  lw t1, z_pressed
  or t0, t0, t1
  lw t1, x_pressed
  or t0, t0, t1
  lw t1, c_pressed
  or t0, t0, t1
  move s0, t0

  beq t0, 0, _wait_first_key

  li t0, 1
  sw t0, game_started

  # real game loop
_game_while:

  jal handle_input

_game_started:
  jal input_get_keys_held

  # Move stuff
  jal update_game
  beq v0, 1, _game_end

  # Draw stuff
  jal draw_game

  # Must update the frame and wait
  jal display_update_and_clear
  jal wait_for_next_frame

  # Leave if x was pressed
  lw t0, x_pressed
  bnez t0, _game_end

  j _game_while

_game_end:
  # display whole frame as black
  li a0, 0      # x
  li a1, 0      # y
  li a2, DISPLAY_W  # width
  li a3, DISPLAY_H  # height
  li v1, COLOR_BLACK
  jal display_fill_rect

  li a0, 5
  li a1, 5
  lstr a2, "Score "
  jal display_draw_text

  li a0, 38
  li a1, 5
  jal get_score
  move a2, v0
  jal display_draw_int

  # Clear the screen
  jal display_update_and_clear
  jal wait_for_next_frame

  leave
