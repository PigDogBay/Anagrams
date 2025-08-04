/*

Tool to convert ZX font (see https://damieng.com/zx-origins) 
to Next 4-bit sprite sheet. 
The fonts have a vertical color gradient, drop shadow and background transparency.

The code composites the following:

    Transparency layer
    Shadow layer
    Color layer with vertical gradient

Each 1 bit pixel of the font is convert to 4bit nibble whose color index depends on the tiles row (1 to 8)
A shadow font is also created which is black (0 index) and shifted down and left 1 pixel
For any pixels not set, transparency index is used (0xf)

Compile:
gcc tools/FontGradient.c -o bin/fontGradient.o

Run:
./bin/fontGradient.o

*/



#include <stdio.h>
#include "TruffleShuffle.h"

void convert1BitTo4BitPixels(unsigned char *buff, unsigned char byte, unsigned char value);

// A tile requires 8 * 8 = 64 nibbles
unsigned char buffer[32];
unsigned char shadowBuffer[32];

static const uint8_t TRANSPARENCY_INDEX = 0x0f;
static const uint8_t SHADOW_INDEX = 0x00;


void fillShadowWithTransparency(){
    for (int i=0; i<32; i=i+1){
        shadowBuffer[i] = TRANSPARENCY_INDEX <<4 | TRANSPARENCY_INDEX;
    }
}

void bitsToNibbles(unsigned char byte, int row){
    convert1BitTo4BitPixels(&buffer[row*4],byte,row+1);
    if (row < 7) {
        //shift to the left
        byte = byte>>1;
        convert1BitTo4BitPixels(&shadowBuffer[(row+1)*4],byte,1);
    }
}

void combine(){
    uint8_t combined,shadow, top, bottom, shadowTop, shadowBottom;

    for (int i=0;i<32; i=i+1){
        top = buffer[i] >> 4;
        bottom = buffer[i] & 0x0f;
        shadowTop = shadowBuffer[i] >> 4;
        shadowBottom = shadowBuffer[i] & 0x0f;

        if (shadowTop == 1){
            shadowTop = SHADOW_INDEX;
        } else {
            shadowTop = TRANSPARENCY_INDEX;
        }
        if (shadowBottom == 1){
            shadowBottom = SHADOW_INDEX;
        } else {
            shadowBottom = TRANSPARENCY_INDEX;
        }
        //Overwrite shadow nibbles if pixel layer is set
        if (top !=0){
            shadowTop = top;
        }
        if (bottom !=0){
            shadowBottom = bottom;
        }
        combined = shadowTop << 4 | shadowBottom;
        shadowBuffer[i] = combined;
    }
}

void convert1BitTo4BitPixels(unsigned char *buff, unsigned char byte, unsigned char value) {
    unsigned char upperNibble = 0;
    unsigned char lowerNibble = 0;

    for (int i = 0; i < 8; i=i+2) {
        
        // Upper nibble
        int bitPosition = 7 - i;
        unsigned char mask = (1 << bitPosition);
        if ((byte & mask) != 0) {
            upperNibble = value << 4;
        } else {
            upperNibble = 0;
        }

        // Lower nibble
        bitPosition--;
        mask = (1 << bitPosition);
        if ((byte & mask) != 0) {
            lowerNibble = value;
        } else {
            lowerNibble = 0;
        }
        
        buff[i/2] = upperNibble | lowerNibble;

    }
}

void printBuffer() {
    for (int i = 0; i<32; i=i+4){
        printf("%02X%02X%02X%02X   %02X%02X%02X%02X\n",
            buffer[i],buffer[i+1],buffer[i+2],buffer[i+3],
            shadowBuffer[i],shadowBuffer[i+1],shadowBuffer[i+2],shadowBuffer[i+3]);
    }
}


void createGradientShadowTile(const unsigned char *pixels) { 
    fillShadowWithTransparency();
    for (int i = 0; i<8; i=i+1){
        bitsToNibbles(*pixels,i);
        pixels++;
    }
    combine();

//    printBuffer();
}

int main() { 
    printf("Font To Tile\n");
    printf("Converting Font\n");

    FILE* filePointer = NULL;
    filePointer = fopen("assets/font.spr","wb");
    if (filePointer==NULL){
        perror("Unable to open file");
        return 1;
    }

    for (int i = 0; i < FONT_SIZE; i = i + 8)
    {
        createGradientShadowTile(&FONT_TRUFFLE_SHUFFLE_BITMAP[i]);
        size_t bytesWritten = fwrite(shadowBuffer, sizeof(unsigned char), 32, filePointer);

        if (bytesWritten != 32) {
            perror("Error writing buffer to file");
            fclose(filePointer);
            return 1; // Indicate an error
        }

    }

    fclose(filePointer);
    printf("Success\n");
    return 0;
}
