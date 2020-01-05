/**
 * Get the key that was pressed, if any. Returns 0 if no key was pressed.
 */
int getkey();
/**
 * Sleep for 1 second.
 */
void sleep();

/**
 * Draws a 10x10px cell to the screen.
 */
void draw_cell(char x, char y, char colour);

/**
 * Clears the screen
 */
void cls();

/**
 * Invokes the Bochs breakpoint
 */
void brk();
