/**
 * Get the key that was pressed, if any. Returns 0 if no key was pressed.
 */
int getkey();
/**
 * Sleep for 1 second.
 */
void sleep();

/**
 * Draws a 10x10px cell to the screen. xy is x + 0x100*y.
 */
void draw_cell(int xy, char colour);

/**
 * Clears the screen
 */
void cls();

void shutdown();
