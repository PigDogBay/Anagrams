/*

Tool to convert ZX font (see https://damieng.com/zx-origins) 
to Next 4-bit sprite sheet

Each 1 bit pixel of the font is convert to 4bit nibble

*/

#include <stdio.h>
#include "Magnetic.h"

unsigned char buffer[4];

void convert1BitTo4BitPixels(unsigned char byte) {
    unsigned char upperNibble = 0;
    unsigned char lowerNibble = 0;

    for (int i = 0; i < 8; i=i+2) {
        
        // Upper nibble
        int bitPosition = 7 - i;
        unsigned char mask = (1 << bitPosition);
        if ((byte & mask) != 0) {
            upperNibble = 0x10;
        } else {
            upperNibble = 0;
        }

        // Lower nibble
        bitPosition--;
        mask = (1 << bitPosition);
        if ((byte & mask) != 0) {
            lowerNibble = 1;
        } else {
            lowerNibble = 0;
        }
        
        buffer[i/2] = upperNibble | lowerNibble;

    }
}

void printBuffer() {
    printf("%02X,%02X,%02X,%02X\n\n",buffer[0],buffer[1],buffer[2],buffer[3]);
}

int main() { 
    printf("Font To Tile\n");
    printf("Converting Magnetic Font\n");

    FILE* filePointer = NULL;
    filePointer = fopen("assets/magnetic.spr","wb");
    if (filePointer==NULL){
        perror("Unable to open file");
        return 1;
    }

    for (int i = 0; i < FONT_MAGNETIC_SIZE; i++)
    {
        convert1BitTo4BitPixels(FONT_MAGNETIC_BITMAP[i]);
        size_t bytesWritten = fwrite(buffer, sizeof(unsigned char), 4, filePointer);

        if (bytesWritten != 4) {
            perror("Error writing buffer to file");
            fclose(filePointer);
            return 1; // Indicate an error
        }

    }

    fclose(filePointer);
    printf("Success\n");
    return 0;
}
