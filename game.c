#include <stdint.h>
#include "utils.h"

#define SNAKE_SIZE 100

#define X_LIMIT 32
#define Y_LIMIT 20

// Whack everything in bss by setting it all to zero. Each value is
// x + 0x100*y
int snake[SNAKE_SIZE + 1] = {0};
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

    // snake starts motionless.
    short motion = 0;

    while (1) {
        char key = getkey();
        if (key) {
            // Extract bits 1 and 2 and lookup motion in table above. We do no
            // validation of the key so other keys will go in random directions
            // but oh well
            char idx = (key >> 1) & 0x03;
            motion = scan_table[idx];
        }
        
        // Advance the snake
        for (int i = length; i; i--) {
            snake[i] = snake[i - 1];
        }

        snake[0] += motion;

        repaint();
        sleep();
    }
}

void repaint() {
    cls();

    for (int i = 0; i < length; i++) {
        draw_cell(snake[i], 0xF);
    }
}
