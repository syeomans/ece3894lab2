#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

//function to convert ascii char[] to hex-string (char[])
void string2hexString(char* input, char* output)
{
    int loop;
    int i;

    i=0;
    loop=0;

    while(input[loop] != '\0')
    {
        sprintf((char*)(output+i),"%02X", input[loop]);
        loop+=1;
        i+=2;
    }
    //insert NULL at the end of the output string
    output[i++] = '\0';
}

// static unsigned char gethex(const char *s, char **endptr) {
//   assert(s);
//   while (isspace(*s)) s++;
//   assert(*s);
//   return strtoul(s, endptr, 16);
// }
//
// unsigned char *convert(const char *s, int *length) {
//   unsigned char *answer = malloc((strlen(s) + 1) / 3);
//   unsigned char *p;
//   for (p = answer; *s; p++)
//     *p = gethex(s, (char **)&s);
//   *length = p - answer;
//   return answer;
// }

int main()
{
    char *cp, key[8];
    char x[8] = {0x42, 0x00, 0x43, 0x00, 0x00, 0x00, 0x76, 0x00};

    // for (int k; k<sizeof(key); k++)
    // {
    //     printf("%d", key[k]);
    // }

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
    char * ptr;

    int i;

    // Open key file
    keyPointer = fopen("Key.txt", "r");

    // Read Key.txt line-by-line
    while ((keyRead = getline(&keyLine, &keyLen, keyPointer)) != -1)
    {
        // Copy the contents of the current keyLine to key
        memcpy(key, keyLine, sizeof(key));

        // Open text file on every loop
        textPointer = fopen("Plaintextin.txt", "r");

        // Read Plaintextin.txt line-by-line
        while ((textRead = getline(&textLine, &textLen, textPointer)) != -1)
        {
            // Copy the contents of the current textLine to x
            memcpy(x, textLine, sizeof(x));

            // // Delete this later
            // for (int i=0; i<sizeof(x); i++)
            // {
            //     printf("%x %c\n",x[i], x[i]);
            // }

        }
        // Close text file on every loop
        fclose(textPointer);
    }
    // Close Key file
    fclose(keyPointer);

    return 0;
}
