## This file only defines .eqv so that it can be included by other files

## arena const
.eqv ARENA_WIDTH    12
.eqv ARENA_HEIGHT   11
.eqv INFO_HEIGHT    9   # height of bottom information region
.eqv BLOCK_SIZE     5   # by pixel

## offset of struct
.eqv ENTITY_X       0
.eqv ENTITY_Y       4
.eqv ENTITY_STATE   8
.eqv ENTITY_INVINC_FRAME  12   # max lives

# arena cell type
.eqv ARENA_WALL     1
.eqv ARENA_SPACE    0
.eqv ARENA_MACGUF   2   # MacGuffin

# player state
.eqv STATE_NORMAL   0
.eqv STATE_INVINCIBLE   1   # invincible
