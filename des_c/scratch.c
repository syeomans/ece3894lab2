#include <stdio.h>
#include <string.h>
#define _GNU_SOURCE
#include <stdlib.h>

int main()
{
    char *cp, key[8] = {0x75, 0x02, 0x76, 0x98, 0x03, 0x48, 0x51, 0x30};
    char x[8] = {0x42, 0x00, 0x43, 0x00, 0x00, 0x00, 0x76, 0x00};

    for (int k; k<sizeof(key); k++)
    {
        printf("%d", key[k]);
    }

    FILE *writeFile;
    writeFile = fopen("test.txt", "w+");
    fprintf(writeFile, "This is testing for fprintf...\n");
    fputs("This is testing for fputs...\n", writeFile);
    fclose(writeFile);

    // I/O variable declarations for Key.txt
    FILE * keyPointer;
    char * keyLine = NULL; // Useful value stored here
    size_t keyLen = 0;
    ssize_t keyRead;

    // I/O variable declarations for Plaintextin.txt
    FILE * textPointer;
    char * textLine = NULL; // Useful value stored here
    size_t textLen = 0;
    ssize_t textRead;

    int num;
    char tmpString[2];

    int i;

    // Open key file
    keyPointer = fopen("Key.txt", "r");

    // Read Key.txt line-by-line
    while ((keyRead = getline(&keyLine, &keyLen, keyPointer)) != -1)
    {
        // Open text file on every loop
        textPointer = fopen("Plaintextin.txt", "r");

        // Read Plaintextin.txt line-by-line
        while ((textRead = getline(&textLine, &textLen, textPointer)) != -1)
        {
            // Do something here
            // Break keyLine string into two-character pieces and assign to key array
            for(i=0; i<16; i=i+2)
            {
                memcpy( tmpString, &keyLine[i], 2 );
                key[i/2] = atoi(tmpString);
            }

            // Break textLine string into two-character pieces and assign to x array
            for(i=0; i<16; i=i+2)
            {
                memcpy( tmpString, &textLine[i], 2 );
                x[i/2] = atoi(tmpString);
            }

            for (i=0; i< sizeof(key); i++)
            {
                printf("%d ", key[i]);
            }
            printf("\t");

            for (i=0; i< sizeof(x); i++)
            {
                printf("%d ", x[i]);
            }
            printf("\n");



            // for(int i=0; i<=16; i++)
            // {
            //     memcpy( tmpString, &keyLine[i], 2 );
            //     num = (int)strtol(tmpString, NULL, 16);
            //     //key[i] = num;
            //     printf("%X ", num);
            // }
            // printf("\n");
            //
            // for(int i=0; i<=16; i++)
            // {
            //     memcpy( tmpString, &textLine[i], 2 );
            //     num = (int)strtol(tmpString, NULL, 16);
            //     //key[i] = num;
            //     printf("%X ", num);
            // }
            // printf("\n\n");
            // // printf("%s %s\n", strtok(keyLine, "\n"), strtok(textLine, "\n"));
            // // num = (int)strtol(keyLine, NULL, 16);
            // // printf("%X\n", num);
            // // // printf("%s", textLine);
        }
        // Close text file on every loop
        fclose(textPointer);
    }
    // Close Key file
    fclose(keyPointer);

    return 0;
}
