.include "includes.asm"

.data
macguffin_pattern_yellow1:    # yellow
  .byte COLOR_YELLOW,  COLOR_NONE,   COLOR_YELLOW, COLOR_NONE,   COLOR_YELLOW
  .byte COLOR_NONE,    COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_NONE
  .byte COLOR_YELLOW,  COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW
  .byte COLOR_NONE,    COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_NONE
  .byte COLOR_YELLOW,  COLOR_NONE,   COLOR_YELLOW, COLOR_NONE,   COLOR_YELLOW
macguffin_pattern_yellow2:    # small star
  .byte COLOR_NONE,   COLOR_YELLOW, COLOR_NONE,   COLOR_YELLOW, COLOR_NONE
  .byte COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW
  .byte COLOR_NONE,   COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_NONE
  .byte COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW
  .byte COLOR_NONE,   COLOR_YELLOW, COLOR_NONE,   COLOR_YELLOW, COLOR_NONE
macguffin_pattern_red1:
    .byte COLOR_RED, COLOR_NONE, COLOR_RED, COLOR_NONE, COLOR_RED
    .byte COLOR_NONE, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_NONE
    .byte COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED
    .byte COLOR_NONE, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_NONE
    .byte COLOR_RED, COLOR_NONE, COLOR_RED, COLOR_NONE, COLOR_RED
macguffin_pattern_red2:
    .byte COLOR_NONE, COLOR_RED, COLOR_NONE, COLOR_RED, COLOR_NONE
    .byte COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED
    .byte COLOR_NONE, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_NONE
    .byte COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED, COLOR_RED
    .byte COLOR_NONE, COLOR_RED, COLOR_NONE, COLOR_RED, COLOR_NONE
macguffin_pattern_blue1:
    .byte COLOR_BLUE, COLOR_NONE, COLOR_BLUE, COLOR_NONE, COLOR_BLUE
    .byte COLOR_NONE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_NONE
    .byte COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE
    .byte COLOR_NONE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_NONE
    .byte COLOR_BLUE, COLOR_NONE, COLOR_BLUE, COLOR_NONE, COLOR_BLUE
macguffin_pattern_blue2:
    .byte COLOR_NONE, COLOR_BLUE, COLOR_NONE, COLOR_BLUE, COLOR_NONE
    .byte COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE
    .byte COLOR_NONE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_NONE
    .byte COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE
    .byte COLOR_NONE, COLOR_BLUE, COLOR_NONE, COLOR_BLUE, COLOR_NONE

.text

# draw a whole game frame according model data
.globl draw_game
draw_game:
  enter s0, s1

  # display whole frame as black
  li a0, 0      # x
  li a1, 0      # y
  li a2, DISPLAY_W  # width
  li a3, DISPLAY_H  # height
  li v1, COLOR_BLACK
  jal display_fill_rect

  jal draw_arena
  jal draw_info
  jal draw_player
  jal draw_enemies

  leave s0, s1

# draw wall/macguffin block in arena data
.globl draw_arena
draw_arena:
  enter s0, s1, s2, s3, s4, s5

  # get current frame_counter
  lw s5, frame_counter

  # loop, for (s0,s1)=arena(x,y), s2:cell, (s3,s4)=display(x,y)
  move s0, zero  # x = 0
_arena_loop_x:
  move s1, zero  # y = 0

  _arena_loop_y:
    # get arena[x][y]
    move a0, s0
    move a1, s1
    jal get_arena_cell
    move s2, v0

    # compute coordinate
    mul s3, s0, BLOCK_SIZE  # display_x = x * 5
    mul s4, s1, BLOCK_SIZE  # display_y = y * 5

    # switch cell type
    beq s2, ARENA_WALL, _draw_wall
    beq s2, ARENA_MACGUF, _draw_macguffin
    j _next_cell

    _draw_wall:
      # draw 5x5 white block
      move a0, s3  # x
      move a1, s4  # y
      li a2, BLOCK_SIZE
      li a3, BLOCK_SIZE
      li v1, COLOR_WHITE
      jal display_fill_rect

      # draw green square
      move a0, s3      # x
      move a1, s4      # y

      # location depeneds on odd/even
      move t0, s0      # global x
      move t1, s1      # global y
      add t2, t0, t1   # x + y
      andi t2, t2, 1   # last bit odd/even

      beqz t2, _draw_wall_even_pattern
      j _draw_wall_odd_pattern

    _draw_wall_even_pattern:
      # draw 2x2 green block at left top
      move a0, s3
      move a1, s4
      li a2, 2
      li a3, 2
      li v1, COLOR_GREEN
      jal display_fill_rect

      # draw 2x2 green block at right top
      addi a0, s3, 3
      move a1, s4
      li a2, 2
      li a3, 2
      jal display_fill_rect

      # draw 2x2 green block at left bottom
      move a0, s3
      addi a1, s4, 3
      li a2, 2
      li a3, 2
      jal display_fill_rect

      # draw 2x2 green block at right bottom
      addi a0, s3, 3
      addi a1, s4, 3
      li a2, 2
      li a3, 2
      jal display_fill_rect
      j _next_cell

    _draw_wall_odd_pattern:
      # draw 1x2 green block at center top
      addi a0, s3, 2
      move a1, s4
      li a2, 1
      li a3, 2
      li v1, COLOR_GREEN
      jal display_fill_rect

      # draw 1x2 green block at center bottom
      addi a0, s3, 2
      addi a1, s4, 3
      li a2, 1
      li a3, 2
      jal display_fill_rect

      # draw 2x1 green block at left
      move a0, s3
      addi a1, s4, 2
      li a2, 2
      li a3, 1
      jal display_fill_rect

      # draw 1x2 green block at righ
      addi a0, s3, 3
      addi a1, s4, 2
      li a2, 2
      li a3, 1
      jal display_fill_rect

      j _next_cell

    _draw_macguffin:
      move a0, s3 # dispaly x
      move a1, s4 # dispaly y

      # draw red MacGuffin at (9,2)
      li t1, 9
      li t2, 2
      bne s0, t1, _use_pattern_blue   # arena.x != 9
      bne s1, t2, _use_pattern_blue   # arena.y != 2

      # s5=frame_count % 32, and draw 2 pattern accordingly
      andi t0, s5, 32
      beqz t0, _use_pattern_red1
      la a2, macguffin_pattern_red2
      j _draw_pattern
    _use_pattern_red1:
      la a2, macguffin_pattern_red1
      j _draw_pattern

    _use_pattern_blue:
      # draw blue MacGuffin at (7,4)
      li t1, 7
      li t2, 4
      bne s0, t1, _use_pattern_yellow    # arena.x != 7
      bne s1, t2, _use_pattern_yellow    # arena.y != 4

      # s5=frame_count % 32, and draw 2 pattern accordingly
      andi t0, s5, 32
      beqz t0, _use_pattern_blue1
      la a2, macguffin_pattern_blue2
      j _draw_pattern
    _use_pattern_blue1:
      la a2, macguffin_pattern_blue1
      j _draw_pattern

    _use_pattern_yellow:
      # s5=frame_count % 32, and draw 2 pattern accordingly
      andi t0, s5, 32
      beqz t0, _use_pattern_yellow1
      la a2, macguffin_pattern_yellow2
      j _draw_pattern
    _use_pattern_yellow1:
      la a2, macguffin_pattern_yellow1

    _draw_pattern:
      jal display_blit_5x5_trans
      j _next_cell

  _next_cell:
    inc s1
    blt s1, ARENA_HEIGHT, _arena_loop_y
    inc s0
    blt s0, ARENA_WIDTH, _arena_loop_x

  leave s0, s1, s2, s3, s4, s5

# draw bottom information of pionts and lives
.globl draw_info
draw_info:
  enter s0, s1

  # draw the blue line
  li a0, 0
  li a1, 55
  li a2, 64
  li a3, COLOR_BLUE
  jal display_draw_hline

  # save s0=score, s1=lives
  jal get_score
  move s0, v0    # s0 = score
  jal get_lives
  move s1, v0    # s1 = lives

  # display "PTS:"
  li a0, 2            # x coordinate
  li a1, 57           # y coordinate
  li a2, 'P'          # character
  li a3, COLOR_WHITE  # color
  jal display_draw_char

  li a0, 8
  li a1, 57
  li a2, 'T'
  jal display_draw_char

  li a0, 14
  li a1, 57
  li a2, 'S'
  jal display_draw_char

  li a0, 20
  li a1, 57
  li a2, ':'
  jal display_draw_char

  # Display score
  li a0, 26      # x coordinate (moved right to accommodate PTS)
  li a1, 57      # y coordinate
  move a2, s0    # score value
  jal display_draw_int

  # draw lives
  li a0, 45      # x
  li a1, 57      # y
  move s0, s1    # s0 = s1 = lives

_draw_lives_loop:
  beqz s0, _end_draw_lives

  # push x,y,lives
  push a0
  push a1
  push s0

  jal draw_player_sprite

  # pop x,y,lives
  pop s0
  pop a1
  pop a0

  addi a0, a0, 6   # display.x += 6
  addi s0, s0, -1  # lives --
  j _draw_lives_loop

_end_draw_lives:
  leave s0, s1

# no one call this!!!
# a0: x, a1: y, a2: number, a3: width
display_draw_small_int:
  enter s0, s1, s2, s3, s4

  move s0, a0    # x position
  move s1, a1    # y position
  move s2, a2    # number to display
  move s3, a3    # width
  li s4, 0       # digit counter

_digit_loop:
  # calculate last digit
  rem t0, s2, 10     # t0 = number % 10
  div s2, s2, 10     # number = number / 10

  # save argument
  push t0
  push s2

  # draw digit
  move a0, s0
  move a1, s1
  move a2, t0
  jal display_draw_digit_5x5  #

  # restore argument
  pop s2
  pop t0

  # next position
  sub s0, s0, 6      #

  #
  inc s4
  blt s4, s3, _digit_loop

  leave s0, s1, s2, s3, s4

# only be called by display_draw_small_int who was never called
# draw digit as 5x5
# a0: x, a1: y, a2: digit (0-9)
display_draw_digit_5x5:
  enter

  # change display_draw_5x5 as needed

  leave

.globl draw_player
draw_player:
  enter s0, s1

  # player struct
  jal get_player
  move s0, v0

  # splink if invic
  lw s1, ENTITY_STATE(s0)
  andi t0, s1, STATE_INVINCIBLE
  beqz t0, _draw

  # switch state per 4 frame
  lw t0, frame_counter
  andi t0, t0, 16
  bnez t0, _skip_draw_player

_draw:
  # calculate coordinate
  lw t0, ENTITY_X(s0)
  mul a0, t0, BLOCK_SIZE
  lw t0, ENTITY_Y(s0)
  mul a1, t0, BLOCK_SIZE
  jal draw_player_sprite

_skip_draw_player:
  leave s0, s1

# no argument
draw_enemies:
  enter s0, s1

  li s0, 0                      # for i = 0
_enemy_loop:
  move a0, s0
  jal get_enemy                 # get enemy data addr
  move s1, v0

  lw t0, ENTITY_X(s1)           # calculate location
  mul a0, t0, BLOCK_SIZE
  lw t0, ENTITY_Y(s1)
  mul a1, t0, BLOCK_SIZE

  jal draw_enemy_sprite

  inc s0                        # i++
  blt s0, NUM_ENEMIES, _enemy_loop

  leave s0, s1
