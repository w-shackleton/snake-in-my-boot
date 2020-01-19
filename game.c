#include <stdint.h>
#include "utils.h"

#define SNAKE_SIZE 100

#define X_LIMIT 32
#define Y_LIMIT 20

// Whack everything in bss by setting it all to zero. Each value is
// x + 0x100*y
int snake[SNAKE_SIZE + 1] = {0};
short food = 0x0402;
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

void repaint();
void print();

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
        length += new_head == food;
        
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
        // TODO: make game area be 32x20, not 32x16
        if (snake[0] & 0xF0E0) {
            shutdown();
        }

        repaint();
        sleep();
    }
}

void repaint() {
    cls();

    draw_cell(food, 0x9);

    for (int i = 0; i < length; i++) {
        draw_cell(snake[i], 0xF);
    }
}
