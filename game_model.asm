.include "includes.asm"

.data
arena: .byte                 # 12x11 refer to ARENA_*
    1,1,1,1,1,1,1,1,1,1,1,1
    1,0,2,0,2,0,2,0,2,0,2,1
    1,2,1,2,1,1,1,2,1,2,0,1  # a MacGuffin
    1,0,2,0,2,1,1,0,2,0,2,1
    1,0,1,1,0,2,0,2,1,1,0,1  # a MacGuffin
    1,0,2,0,2,1,1,0,0,0,2,1
    1,0,1,1,0,2,0,0,1,1,0,1
    1,2,0,1,0,1,1,2,1,2,2,1  # a MacGuffin
    1,0,0,1,0,1,1,2,2,0,2,1
    1,2,0,2,0,2,0,2,0,2,1,1  # a MacGuffin
    1,1,1,1,1,1,1,1,1,1,1,1

player: .space ENTITY_SIZE   # player struct
lives:  .word 3              # lives left
score:  .word 0
enemies:
  .word 4, 7, ENEMY_UP, 0     # x, y, direction, NA
  .word 7, 5, ENEMY_RIGHT, 0  # x, y, direction, NA
  .word 9, 8, ENEMY_DOWN, 0   # x, y, direction, NA

.text
# initialize player data
.globl init_game
init_game:
  enter s0
  # initialize player state and position
  la s0, player
  li t0, 1
  sw t0, ENTITY_X(s0)    # x = 1
  li t0, 1
  sw t0, ENTITY_Y(s0)    # y = 1
  sw zero, ENTITY_STATE(s0) # set normal state
  li t0, 3
  sw t0, lives           # set max lives
  sw zero, score         # set score 0
  jal init_enemies
  leave s0

# get cell type in arena
# arguments:
# a0 = x
# a1 = y
.globl get_arena_cell
get_arena_cell:
  mul t0, a1, ARENA_WIDTH  # y * width
  add t0, t0, a0           # + x
  la t1, arena
  add t1, t1, t0
  lb v0, (t1)
  jr ra

# set cell type in arena
# arguments:
# a0 = x
# a1 = y
# a2 = cell type
.globl set_arena_cell
set_arena_cell:
  mul t0, a1, ARENA_WIDTH
  add t0, t0, a0
  la t1, arena
  add t1, t1, t0
  sb a2, (t1)
  jr ra

## return macguffin numbers on arena
.globl get_macguffin_number
get_macguffin_number:
  enter

  li t0, 0                      # loop i
  li t1, 0                      # macguffin counter
  la t2, arena                  # array addr
_loop:
  add t3, t2, t0
  lb t4, (t3)
  bne t4, 2, _is_loop_end
  inc t1
_is_loop_end:
  inc t0
  blt t0, 121, _loop

  move v0, t1
  leave

# get player data addr
.globl get_player
get_player:
  la v0, player
  jr ra

# get player lives left
.globl get_lives
get_lives:
  lw v0, lives
  jr ra

.globl dec_lives
dec_lives:
  lw t0, lives
  dec t0
  sw t0, lives
  jr ra

# get player score
.globl get_score
get_score:
  lw v0, score
  jr ra

# set player score
# arguments:
# a0 = new score
.globl set_score
set_score:
  sw a0, score
  jr ra

# init 3 enemies's location and direction
init_enemies:
  enter s0

  leave s0

# get a0-th enemy data addr
.globl get_enemy
get_enemy:
    mul t0, a0, ENTITY_SIZE  # i * ENTITY_SIZE
    la t1, enemies
    add v0, t1, t0
    jr ra
