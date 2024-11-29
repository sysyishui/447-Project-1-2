# sprites.asm
.include "includes.asm"

.data
# player 5x5
player_sprite:
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_RED,    COLOR_ORANGE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_RED,    COLOR_RED,    COLOR_RED,    COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_RED,    COLOR_ORANGE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE

# MacGuffin 5x5
macguffin_sprite:
   .byte COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW
   .byte COLOR_YELLOW, COLOR_NONE,   COLOR_NONE , COLOR_NONE, COLOR_YELLOW
   .byte COLOR_YELLOW, COLOR_NONE,   COLOR_YELLOW, COLOR_NONE, COLOR_YELLOW
   .byte COLOR_YELLOW, COLOR_NONE,   COLOR_NONE, COLOR_NONE, COLOR_YELLOW
   .byte COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW, COLOR_YELLOW

macguffin_sprite2:
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_NONE, COLOR_ORANGE, COLOR_NONE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_ORANGE
   .byte COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE, COLOR_ORANGE

# blue 1
macguffin_sprite3:
   .byte COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE
   .byte COLOR_BLUE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_BLUE
   .byte COLOR_BLUE, COLOR_NONE, COLOR_BLUE, COLOR_NONE, COLOR_BLUE
   .byte COLOR_BLUE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_BLUE
   .byte COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE, COLOR_BLUE

# blue alternateive
macguffin_sprite3_alt:
  .byte COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE
  .byte COLOR_DARK_BLUE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_DARK_BLUE
  .byte COLOR_DARK_BLUE, COLOR_NONE, COLOR_DARK_BLUE, COLOR_NONE, COLOR_DARK_BLUE
  .byte COLOR_DARK_BLUE, COLOR_NONE, COLOR_NONE, COLOR_NONE, COLOR_DARK_BLUE
  .byte COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE, COLOR_DARK_BLUE

enemy_sprite:
  .byte COLOR_NONE, COLOR_MAGENTA, COLOR_NONE, COLOR_MAGENTA, COLOR_NONE
  .byte COLOR_MAGENTA, COLOR_BLACK, COLOR_MAGENTA, COLOR_BLACK, COLOR_MAGENTA
  .byte COLOR_MAGENTA, COLOR_MAGENTA, COLOR_BLACK, COLOR_MAGENTA, COLOR_MAGENTA
  .byte COLOR_MAGENTA, COLOR_PURPLE, COLOR_MAGENTA, COLOR_PURPLE, COLOR_MAGENTA
  .byte COLOR_PURPLE, COLOR_NONE, COLOR_PURPLE, COLOR_NONE, COLOR_PURPLE

.text

.globl draw_player_sprite
draw_player_sprite:
   enter
   la a2, player_sprite
   jal display_blit_5x5_trans
   leave

# no one call this!!!
# MacGuffin as frame_counter
.globl draw_macguffin_sprite
draw_macguffin_sprite:
   enter s0, s1

   # save location and frame
   move s0, a0  # x
   move s1, a1  # y
   lw t0, frame_counter
   andi t0, t0, 32  # switch sprite

   # location of first MacGuffin(9,2)
   li t1, 9
   li t2, 2
   bne s0, t1, _check_second
   bne s1, t2, _check_second

   # yellow MacGuffin
   beqz t0, _use_yellow1
   la a2, macguffin_sprite2
   j _draw
_use_yellow1:
   la a2, macguffin_sprite
   j _draw

_check_second:
   # second MacGuffin(7,4)
   li t1, 7
   li t2, 4
   bne s0, t1, _check_third
   bne s1, t2, _check_third

   # orange MacGuffin
   la a2, macguffin_sprite2
   j _draw

_check_third:
   # third blue MacGuffin
   beqz t0, _use_blue1
   la a2, macguffin_sprite3_alt
   j _draw
_use_blue1:
   la a2, macguffin_sprite3

_draw:
   jal display_blit_5x5_trans
   leave s0, s1

# argument: a0=enemy.x a1=enemy.y a2=sprite_array
.globl draw_enemy_sprite
draw_enemy_sprite:
  enter
  la a2, enemy_sprite
  jal display_blit_5x5_trans
  leave
