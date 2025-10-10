/*
MPD Bailey Technology
2nd Oct 2025

Converts next colour RRRGGGBBB to standard 24bit RGB value

Compile:
gcc tools/Palette.c -o bin/Palette.o

Run:
./bin/Palette.o

*/

#include <stdio.h>
#include <stdlib.h>

int colourSteps[] = {0, 36, 73, 109, 146, 182, 219, 255};


/**
 * @brief Converts a 9-bit color value from BRRRGGGBB format to RRRGGGBBB format.
 * * Input format (9 bits, 0x1FF max): B RRR GGG BB
 * Target format (9 bits, 0x1FF max): RRR GGG BBB
 * * @param input_9bit The 9-bit color value in BRRRGGGBB format.
 * @return The 9-bit color value in RRRGGGBBB format.
 */
unsigned int convert_brrrgggbb_to_rrrgggbbb(int input_9bit) {
    // 1. Red Component (RRR): Bits 7, 6, 5 (in input) -> Target Bits 8, 7, 6
    // Mask: 0b011100000 (0x1C0). Shift left by 1 (7->8, 6->7, 5->6 relative to the 9-bit structure).
    unsigned int red_repositioned = (input_9bit & 0b011100000) << 1;

    // 2. Green Component (GGG): Bits 4, 3, 2 (in input) -> Target Bits 5, 4, 3
    // Mask: 0b000011100 (0x038). Shift left by 1 (4->5, 3->4, 2->3).
    unsigned int green_repositioned = (input_9bit & 0b00011100) << 1;

    // 3. Blue Component (BBB):
    //    a) LSB: Bit 8 (B_new) -> Target Bit 2
    //       Mask: 0b100000000 (0x100). Shift right by 8 (8 -> 0).
    unsigned int blue_lsb_repositioned = (input_9bit & 0x100) >> 8;

    //    b) LSBs: Bits 1, 0 (BB) -> Target Bits 1, 0 (no shift required).
    //       Mask: 0b000000011 (0x003).
    unsigned int blue_msbs = (input_9bit & 0x03) << 1;

    // Combine all components into the RRRGGGBBB format.
    unsigned int output_9bit_rrrgggbbb = red_repositioned | green_repositioned | blue_lsb_repositioned | blue_msbs;
    
    printf("Input (BRRRGGGBB): 0x%03X -> Rearranged (RRRGGGBBB): 0x%03X (%d)\n", input_9bit, output_9bit_rrrgggbbb, output_9bit_rrrgggbbb);

    return output_9bit_rrrgggbbb;
}

/**
 * @brief Converts a 9-bit color value (RRRGGGBBB) into a 24-bit RGB value (0xRRGGBB).
 * * The 9-bit value is broken down into three 3-bit indices (R, G, B), and each
 * index is used to look up its corresponding 8-bit intensity value from the LUT.
 * * @param color_9bit The 9-bit color value (0-511).
 * @return The resulting 24-bit color value (0xRRGGBB).
 */
unsigned int convert_9bit_to_24bit(int color_9bit) {
    // 1. Extract the 3-bit indices for Blue, Green, and Red using bitwise masks and shifts.
    // The 9-bit structure is: [ RRR | GGG | BBB ]

    // Extract Blue index (lowest 3 bits: 0b111 or 0x7)
    int blue_index = color_9bit & 0x7;

    // Extract Green index (next 3 bits, shifted right by 3)
    int green_index = (color_9bit >> 3) & 0x7;

    // Extract Red index (highest 3 bits, shifted right by 6)
    int red_index = (color_9bit >> 6) & 0x7;

    // 2. Use the indices to look up the 8-bit intensity values (0-255) from the LUT.
    int r_24bit = colourSteps[red_index];
    int g_24bit = colourSteps[green_index];
    int b_24bit = colourSteps[blue_index];

    // 3. Combine the three 8-bit components into a single 24-bit (unsigned int) result (0xRRGGBB).
    // Red gets shifted 16 bits left, Green 8 bits left.
    unsigned int color_24bit = (r_24bit << 16) | (g_24bit << 8) | b_24bit;

    printf("--- Input 9-bit: %d ---\n", color_9bit);
    printf("Indices (R: %d, G: %d, B: %d)\n", red_index, green_index, blue_index);
    printf("24-bit Components (R: %02X, G: %02X, B: %02X)\n", r_24bit, g_24bit, b_24bit);
    printf("24-bit Hex Result: 0x%06X\n\n", color_24bit);

    return color_24bit;
}

void convert_9bit_to_Next(int color_9bit) {
    int blueLSB = color_9bit & 01;
    int rrrggbb = color_9bit >> 1;
    printf("%x,%x\n",rrrggbb,blueLSB);
}

int main(){
    printf("Convert 9Bi RRRGGGBBB Color to Next's RRRGGGBB, B\n");
    int color_9bit;
    int color_next;

    do {
        printf("Enter a 9-bit color RRRGGGBBB (0 to 511):\n> ");

        // Use %%x format specifier to read the input as a hexadecimal number.
        if (scanf("%x", &color_9bit) != 1) {
            fprintf(stderr, "Error: Invalid input format. Please enter a number.\n");
            return 1;
        }

        // Validate the 9-bit range (0 to 511, or 0x1FF).
        if (color_9bit < 0 || color_9bit > 511) {
            fprintf(stderr, "Error: The value 0x%X is out of the valid 9-bit range (0x000 to 0x1FF).\n", color_9bit);
            return 1;
        }

        convert_9bit_to_Next(color_9bit);
    } while(color_9bit);

}

int main2() { 
    printf("Convert 9Bit Color to 24 Bit\n");
    int color_9bit;
    int color_9bit_rrrgggbbb;

    do {
        printf("Enter a 9-bit color BRRRGGGBB (0 to 511):\n> ");

        // Use %%x format specifier to read the input as a hexadecimal number.
        if (scanf("%x", &color_9bit) != 1) {
            fprintf(stderr, "Error: Invalid input format. Please enter a number.\n");
            return 1;
        }

        // Validate the 9-bit range (0 to 511, or 0x1FF).
        if (color_9bit < 0 || color_9bit > 511) {
            fprintf(stderr, "Error: The value 0x%X is out of the valid 9-bit range (0x000 to 0x1FF).\n", color_9bit);
            return 1;
        }
        // Step 1: Convert the input format BRRRGGGBB to the standard RRRGGGBBB format.
        color_9bit_rrrgggbbb = convert_brrrgggbb_to_rrrgggbbb(color_9bit);

        // Step 2: Call the conversion function to get the 24-bit color value.
        convert_9bit_to_24bit(color_9bit_rrrgggbbb);        

    } while(color_9bit);

    return 0;
}
