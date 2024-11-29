# MMIO Registers
.eqv DISPLAY_CTRL       0xFFFF0000
.eqv DISPLAY_KEYS       0xFFFF0004
.eqv DISPLAY_BASE       0xFFFF0008
.eqv DISPLAY_END        0xFFFF1008
.eqv DISPLAY_SIZE           0x1000

# Display stuff
.eqv DISPLAY_W        64
.eqv DISPLAY_H        64
.eqv DISPLAY_W_SHIFT   6

# LED Colors
.eqv COLOR_BLACK       0
.eqv COLOR_RED         1
.eqv COLOR_ORANGE      2
.eqv COLOR_YELLOW      3
.eqv COLOR_GREEN       4
.eqv COLOR_BLUE        5
.eqv COLOR_MAGENTA     6
.eqv COLOR_WHITE       7
.eqv COLOR_DARK_GREY   8
.eqv COLOR_DARK_GRAY   8
.eqv COLOR_BRICK       9
.eqv COLOR_BROWN       10
.eqv COLOR_TAN         11
.eqv COLOR_DARK_GREEN  12
.eqv COLOR_DARK_BLUE   13
.eqv COLOR_PURPLE      14
.eqv COLOR_LIGHT_GREY  15
.eqv COLOR_LIGHT_GRAY  15
.eqv COLOR_NONE        -1

# Input key flags
.eqv KEY_NONE          0x00
.eqv KEY_UP            0x01
.eqv KEY_DOWN          0x02
.eqv KEY_LEFT          0x04
.eqv KEY_RIGHT         0x08
.eqv KEY_B             0x10
.eqv KEY_Z             0x20
.eqv KEY_X             0x40
.eqv KEY_C             0x80

.eqv MS_PER_FRAME      16 # 60 FPS

# Arena Cell Types
.eqv ARENA_EMPTY  0  #
.eqv ARENA_WALL   1  #
.eqv ARENA_MACGUF 2  # MacGuffin

# Arena Size
.eqv ARENA_WIDTH  12
.eqv ARENA_HEIGHT 11
.eqv BLOCK_SIZE   5   # 5x5

# Enemy direction
.eqv ENEMY_LEFT    0
.eqv ENEMY_UP      1
.eqv ENEMY_RIGHT   2
.eqv ENEMY_DOWN    3
.eqv ENEMY_NONE    4
.eqv ENEMY_FAR     512

# Enemy Count
.eqv NUM_ENEMIES   3
.eqv ENTITY_SIZE   16
.eqv ENEMY_SPEED  31           # must be 2^i-1, skip frames when move
