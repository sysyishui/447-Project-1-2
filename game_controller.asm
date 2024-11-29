.include "includes.asm"

.data
  move_cooldown:    .word 4    # cool down time
  last_move:        .word 0    # last move time
  invinc_colldown:  .word 120  # invinc last frames

.text

# update whole game state, if game end return 1
.globl update_game
update_game:
  enter s0

  jal update_player
  jal update_enemies
  jal update_macguffin

  ## check game end
  jal get_lives
  blt v0, 1, _game_end

  jal get_macguffin_number
  beq v0, 0 _game_end

  li v0, 0                    # game not end
  leave s0

_game_end:
  li v0, 1
  leave s0

## local functions

# -------------------------------------------------------------------------------------------------
# update player.(x,y) when key pressed
update_player:
  enter s0, s1

  ## skip frames until next move frame
  lw t0, frame_counter
  lw t1, last_move
  lw t2, move_cooldown
  sub t3, t0, t1
  blt t3, t2, _end              # no moving if frame_count-last_move < move_cooldown

  jal get_player
  move s0, v0                   # s0 = &player

  ## update invinc state
  lw t0, ENTITY_STATE(s0)
  beq t0, STATE_NORMAL, _after_update_invinc
  lw t0, frame_counter
  lw t1, ENTITY_INVINC_FRAME(s0)
  sub t3, t0, t1
  lw t2, invinc_colldown
  blt t3, t2, _after_update_invinc # invinc last 120 frames
  li t1, STATE_NORMAL
  sw t1, ENTITY_STATE(s0)

_after_update_invinc:
  lw s1, ENTITY_X(s0)           # s1 = player.x

  lw t0, left_pressed
  beqz t0, _check_right         # left not pressed, jump to check right pressed

_check_left:
  dec s1
  move a0, s1                   # a0 = player.x-1
  lw a1, ENTITY_Y(s0)           # a1 = player.y
  jal can_move_to
  beqz v0, _check_right         # can not move left, jump to check right pressed
  sw s1, ENTITY_X(s0)           # play.x --

  lw t0, frame_counter          # update last_move
  sw t0, last_move

_check_right:
  lw s1, ENTITY_X(s0)           # s1 = player.x
  lw t0, right_pressed
  beqz t0, _check_up            # right not pressed, jump to check up pressed
  inc s1
  move a0, s1
  lw a1, ENTITY_Y(s0)
  jal can_move_to
  beqz v0, _check_up            # can not move right, jump to check up pressed
  sw s1, ENTITY_X(s0)

  lw t0, frame_counter          # update last_move
  sw t0, last_move

_check_up:
  lw s1, ENTITY_Y(s0)
  lw t0, up_pressed
  beqz t0, _check_down          #  up not pressed, jump to check down pressed
  dec s1
  lw a0, ENTITY_X(s0)
  move a1, s1
  jal can_move_to
  beqz v0, _check_down          # can not move up, jump to check down pressed
  sw s1, ENTITY_Y(s0)

  lw t0, frame_counter          # update last_move
  sw t0, last_move
_check_down:
  lw s1, ENTITY_Y(s0)
  lw t0, down_pressed
  beqz t0, _end                 # down not pressed, nothing need update
  inc s1
  lw a0, ENTITY_X(s0)
  move a1, s1
  jal can_move_to
  beqz v0, _end                 # can not move down, nothing need udpate
  sw s1, ENTITY_Y(s0)

  lw t0, frame_counter          # update last_move
  sw t0, last_move

_end:
  leave s0, s1

# -------------------------------------------------------------------------------------------------
# can player/enemy move to (a0=x, a1=y)
# return: v0 = 1 if can move
can_move_to:
  enter
  move t0, a0
  move t1, a1
  # reach border?
  bltz t0, _cannot_move
  bge t0, ARENA_WIDTH, _cannot_move
  bltz t1, _cannot_move
  bge t1, ARENA_HEIGHT, _cannot_move
  # wall?
  jal get_arena_cell
  beq v0, ARENA_WALL, _cannot_move
  li v0, 1
  j _exit
_cannot_move:
  li v0, 0
_exit:
  leave

# -------------------------------------------------------------------------------------------------
# return (v0=x, v1=y) of (a0=x, a1=y) by a2=direction
# a2 default is left, if a2 is illegal
get_adjacent_xy:
  enter

  move v0, a0                   # recorde x,y to v0,v1
  move v1, a1

  li t0, ENEMY_LEFT
  beq a2, t0, _return_left
  li t0, ENEMY_RIGHT
  beq a2, t0, _return_right
  li t0, ENEMY_UP
  beq a2, t0, _return_up
  li t0, ENEMY_DOWN
  beq a2, t0, _return_down
_return_left:
  dec v0
  leave
_return_right:
  inc v0
  leave
_return_up:
  dec v1
  leave
_return_down:
  inc v1
  leave

# -------------------------------------------------------------------------------------------------
# can player/enemy move to (a0=x, a1=y), a2=direction
# return: v0 = 1 if can move
can_move_direction:
  enter

  beq a2, ENEMY_LEFT, _update_left
  beq a2, ENEMY_RIGHT, _update_right
  beq a2, ENEMY_UP, _update_up
_update_down:
  inc a1
  j _check_move
_update_up:
  dec a1
  j _check_move
_update_left:
  dec a0
  j _check_move
_update_right:
  inc a0
_check_move:
  jal can_move_to

_exit:
  leave

# -------------------------------------------------------------------------------------------------
# return if (a0,a1) is at an intersection where are 3+ direction to move
# argument: a0=x, a1=y
is_intersection:
  enter s0, s1, s2              # x,y,counter
  # call can_move_direction() for 4 directions and sum into s2
  move s0, a0
  move s1, a1
  li s2, 0

  li a2, ENEMY_UP
  jal can_move_direction
  add s2, s2, v0

  move a0, s0
  move a1, s1
  li a2, ENEMY_DOWN
  jal can_move_direction
  add s2, s2, v0

  move a0, s0
  move a1, s1
  li a2, ENEMY_LEFT
  jal can_move_direction
  add s2, s2, v0

  move a0, s0
  move a1, s1
  li a2, ENEMY_RIGHT
  jal can_move_direction
  add s2, s2, v0

  blt s2, 3, _not_intersection
  li v0, 1
  leave s0, s1, s2
_not_intersection:
  li v0, 0
  leave s0, s1, s2

# -------------------------------------------------------------------------------------------------
# enemy(a0, a1) and player(a2,a3) return (a0-a2)^2+(a1-a3)^2
calculate_distance:
  enter
  sub t0, a0, a2
  sub t1, a1, a3
  mul t0, t0, t0
  mul t1, t1, t1
  add v0, t0, t1
  leave

# -------------------------------------------------------------------------------------------------
# enemy chose a new direction to move where must can move
# chose direction has min distance squared, if not possible, return old direction or reverse
# argument: a0=x, a1=y, a2=old direction of enemy location
# return new direction in v0
chose_new_direction:
  enter s0, s1, s2, s3, s4

  ##  print_str "enter chose_new_direction\n"

  move s0, a0                   # s0 = enemy.x
  move s1, a1                   # s1 = enemy.y

  jal get_player
  lw s2, ENTITY_X(v0)           # s2 = player.x
  lw s3, ENTITY_Y(v0)           # s3 = player.y

_calculate_left_prio:
  move a0, s0
  move a1, s1
  li a2, ENEMY_LEFT
  jal can_move_direction        # if blocked, prio = -1
  beq v0, 0, _left_is_blocked

  sub a0, s0, 1                 # calculate distence
  move a1, s1
  move a2, s2
  move a3, s3
  jal calculate_distance
  j _push_left
_left_is_blocked:
  li v0, ENEMY_FAR                     # means blocked
_push_left:
  push v0
  li t0, ENEMY_LEFT
  push t0

_calculate_up_prio:
  move a0, s0
  move a1, s1
  li a2, ENEMY_UP
  jal can_move_direction        # if blocked, prio = -1
  beq v0, 0, _up_is_blocked

  move a0, s0                 # calculate distence
  sub a1, s1, 1
  move a2, s2
  move a3, s3
  jal calculate_distance
  j _push_up
_up_is_blocked:
  li v0, ENEMY_FAR                     # means blocked
_push_up:
  push v0
  li t0, ENEMY_UP
  push t0

_calculate_right_prio:
  move a0, s0
  move a1, s1
  li a2, ENEMY_RIGHT
  jal can_move_direction        # if blocked, prio = -1
  beq v0, 0, _right_is_blocked

  add a0, s0, 1                 # calculate distence
  move a1, s1
  move a2, s2
  move a3, s3
  jal calculate_distance
  j _push_right
_right_is_blocked:
  li v0, ENEMY_FAR                     # means blocked
_push_right:
  push v0
  li t0, ENEMY_RIGHT
  push t0

_calculate_down_prio:
  move a0, s0
  move a1, s1
  li a2, ENEMY_DOWN
  jal can_move_direction        # if blocked, prio = -1
  beq v0, 0, _down_is_blocked

  move a0, s0                 # calculate distence
  add a1, s1, 1
  move a2, s2
  move a3, s3
  jal calculate_distance
  j _push_down
_down_is_blocked:
  li v0, ENEMY_FAR                     # means blocked
_push_down:
  push v0
  li t0, ENEMY_DOWN
  push t0

  # find min distance
  li t0, 0                      # index
  li t2, ENEMY_NONE             # min direction
  li t1, ENEMY_FAR                     # min distance
_loop:
  pop t4                        # direction
  pop t3                        # distance
  bge t3, t1, _check_loop_end
  move t1, t3                   # min distance
  move t2, t4                    # min direction

_check_loop_end:
  inc t0
  blt t0, 4, _loop

  move v0, t2
  leave s0, s1, s2, s3, s4

# -------------------------------------------------------------------------------------------------
# player move to a macfuffin, update arena and score
update_macguffin:
  enter s0, s1, s2

  # get player location
  jal get_player
  move s0, v0
  lw s1, ENTITY_X(s0)  # x
  lw s2, ENTITY_Y(s0)  # y
  move a0, s1
  move a1, s2

  jal get_arena_cell
  bne v0, ARENA_MACGUF, _no_macguffin # no MacGuffin, nothing to do

  # calculate score, (9,2) has score 10
  li t0, 9
  li t1, 2
  bne s1, t0, _check_second
  bne s2, t1, _check_second
  # first MacGuffin +10 score
  jal get_score
  addi v0, v0, 10               # score += 10
  move a0, v0
  jal set_score
  j _clear_macguffin

_check_second:
  li t0, 7                    # (7,4) has score 5
  li t1, 4
  bne s1, t0, _check_third
  bne s2, t1, _check_third
  # second MacGuffin +5
  jal get_score
  addi v0, v0, 5
  move a0, v0
  jal set_score
  j _clear_macguffin

_check_third:
  jal get_score
  addi v0, v0, 2
  move a0, v0                 # 3rd MacGuffin +2
  jal set_score

_clear_macguffin:
  move a0, s1
  move a1, s2
  li a2, ARENA_EMPTY
  jal set_arena_cell
  # update info at bottom
  jal draw_info

_no_macguffin:
  leave s0, s1, s2

# -------------------------------------------------------------------------------------------------
# check if player at (a0, a1) and udpate player state
update_catch_player:
  enter s0
  jal get_player
  move s0, v0

  lw t0, ENTITY_X(s0)
  lw t1, ENTITY_Y(s0)
  lw t2, ENTITY_STATE(s0)
  beq t2, STATE_INVINCIBLE, _return # player is invincable
  bne t0, a0, _return
  bne t1, a1, _return

  li t2, STATE_INVINCIBLE
  sw t2, ENTITY_STATE(s0)
  jal dec_lives

  ## update frame
  lw t0, frame_counter
  sw t0, ENTITY_INVINC_FRAME(s0)

_return:
  leave s0

# -------------------------------------------------------------------------------------------------
# update 3 enemies location
.globl update_enemies
update_enemies:
  enter s0, s1, s2, s3          # loop index and enemy[i]

  lw t0, frame_counter          # move per ENEMY_SPEED frame
  andi t0, t0, ENEMY_SPEED
  bnez t0, _return

  li s0, 0                      # s0 = index of 3 enemies

_update_enemy_loop:
  move a0, s0                   # a0 = s0 = i
  jal get_enemy                 # get enemy[a0]
  move s1, v0                   # s1 = enemy[i]

  # check if enemy have 3+ choices to move
  lw a0, ENTITY_X(s1)
  lw a1, ENTITY_Y(s1)
  jal is_intersection
  bne v0, 1, _check_move_old_direction

  # chose new direction at 3+ choices to move
  lw a0, ENTITY_X(s1)
  lw a1, ENTITY_Y(s1)
  lw a2, ENTITY_STATE(s1)
  jal chose_new_direction
  sw v0, ENTITY_STATE(s1)       # save new direction and move
  j _move_as_direction

_check_move_old_direction:
  lw a0, ENTITY_X(s1)
  lw a1, ENTITY_Y(s1)
  lw a2, ENTITY_STATE(s1)
  jal can_move_direction
  bnez v0, _move_as_direction   # move as before

  # hits a wall
  lw a0, ENTITY_X(s1)
  lw a1, ENTITY_Y(s1)
  lw a2, ENTITY_STATE(s1)
  jal chose_new_direction
  sw v0, ENTITY_STATE(s1)       # save new direction and move

_move_as_direction:
  lw a0, ENTITY_X(s1)
  lw a1, ENTITY_Y(s1)
  lw a2, ENTITY_STATE(s1)
  jal get_adjacent_xy           # move to new location
  sw v0, ENTITY_X(s1)
  sw v1, ENTITY_Y(s1)

  # check catch player
  move s2, v0
  move s3, v1

  move a0, s2
  move a1, s3
  jal update_catch_player

  # clear macguffin
  move a0, s2
  move a1, s3
  li a2, ARENA_EMPTY
  jal set_arena_cell

_skip_enemy_move:
  inc s0
  blt s0, NUM_ENEMIES, _update_enemy_loop

_return:
  leave s0, s1, s2, s3
