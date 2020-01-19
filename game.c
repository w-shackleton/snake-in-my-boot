#include <stdint.h>
#include "utils.h"

#define SNAKE_SIZE 100

#define X_LIMIT 32
#define Y_LIMIT 20

// Whack everything in bss by setting it all to zero
char snake_x[SNAKE_SIZE + 1] = {0};
char snake_y[SNAKE_SIZE + 1] = {0};
int length = 0;

void repaint();
void print();

void main() {
    snake_x[0] = 1;
    snake_y[0] = 1;
    length = 6;

    char direction = 0;

    while (1) {
        char key = getkey();
        switch (key) {
            case 'w':
            case 'a':
            case 's':
            case 'd':
                direction = key;
                break;
            default:
                break;
        }
        
        // Advance the snake
        for (int i = length; i; i--) {
            snake_x[i] = snake_x[i - 1];
            snake_y[i] = snake_y[i - 1];
        }

        switch (direction) {
            case 'w':
                snake_y[0]--;
                break;
            case 'a':
                snake_x[0]--;
                break;
            case 's':
                snake_y[0]++;
                break;
            case 'd':
                snake_x[0]++;
                break;
        }

        repaint();
        sleep();
    }
}

void repaint() {
    cls();

    for (int i = 0; i < length; i++) {
        draw_cell(snake_x[i] + snake_y[i] * 0x100, 0xF);
    }
}

void print(const char* str) {
    while (*str) {
        /* AH=0x0e, AL=char to print, BH=page, BL=fg color */
        __asm__ __volatile__ ("int $0x10"
                              :
                              : "a" ((0x0e<<8) | *str++),
                                "b" (0x0000));
    }
}
