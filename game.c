#include <stdint.h>
#include "utils.h"

#define X_LIMIT 32
#define Y_LIMIT 16

#define SNAKE_SIZE (X_LIMIT * Y_LIMIT)

// bitwise opposites
#define GAME_AREA_MASK 0x0F1F
#define GAME_AREA_DEAD 0xF0E0

// Whack everything in bss by setting it all to zero. Each value is
// x + 0x100*y
short snake[SNAKE_SIZE + 1] = {0};
short food = 0;
int length = 0;

// w = 0x77 0111 0111
// a = 0x61 0110 0001
// s = 0x73 0111 0011
// d = 0x64 0110 0100
//                ^^
//
// We look at bits 1 and 2 to determine the direction of travel. Since the
// direction is stored in two bytes we can calculate both directions in a
// single addition.
const short scan_table[] = {
    // 00 = a - left
    -1,
    // 01 = s - down
    0x100,
    // 10 = d - right
    1,
    // 11 = w - up
    -0x100,
};

void main() {
    length = 6;

    // snake starts going right.
    short motion = 1;

    while (1) {
        char key = getkey();
        if (key) {
            // Extract bits 1 and 2 and lookup motion in table above. We do no
            // validation of the key so other keys will go in random directions
            // but oh well
            char idx = (key >> 1) & 0x03;
            motion = scan_table[idx];
        }

        short new_head = snake[0] + motion;

        // Grow if snake eats food
        if (new_head == food) {
            length++;
            food = (food * 25173 + 13849) & GAME_AREA_MASK;
        }
        
        // Advance the snake
        for (int i = length; i; i--) {
            short body_part = snake[i - 1];

            // Die if snake eats itself
            if (body_part == new_head) {
                shutdown();
            }

            snake[i] = body_part;
        }

        snake[0] += motion;

        // Screen is 32x16 cells. Bounds-check this with bitwise logic.
        if (snake[0] & GAME_AREA_DEAD) {
            shutdown();
        }

        cls();

        draw_cell(food, 0x9);

        for (int i = 0; i < length; i++) {
            draw_cell(snake[i], 0xF);
        }

        sleep();
    }
}
