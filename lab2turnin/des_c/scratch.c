#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <ctype.h>

int chartohex(char input)
{
    int output;
    if (input == '0')
        output = 0;
    else if (input == '1')
        output = 1;
    else if (input == '2')
        output = 2;
    else if (input == '3')
        output = 3;
    else if (input == '4')
        output = 4;
    else if (input == '5')
        output = 5;
    else if (input == '6')
        output = 6;
    else if (input == '7')
        output = 7;
    else if (input == '8')
        output = 8;
    else if (input == '9')
        output = 9;
    else if (input == 'a' || input =='A')
        output = 10;
    else if (input == 'b' || input =='B')
        output = 11;
    else if (input == 'c' || input =='C')
        output = 12;
    else if (input == 'd' || input =='D')
        output = 13;
    else if (input == 'e' || input =='E')
        output = 14;
    else if (input == 'f' || input =='F')
        output = 15;
    return(output);
}

void hexify(char input[16], char * output)
{
    unsigned int hex1;
    unsigned int hex2;
    unsigned int hexFinal;
    for (int i=0; i<16; i+=2)
    {
        hex1 = chartohex(input[i]);
        hex2 = chartohex(input[i+1]);
        hexFinal = (hex1 << 4) + hex2;
        output[i/2] = hexFinal;
    }
}

void stringify(char input[8], char * output)
{
    //
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
    // char foo[16] = "1ea1789cd57b3af8";
    char foo[16] = "0123456789abcdef";
    char bar[8];
    char * fooptr = foo;

    hexify(foo, bar);
    for (int i=0; i<8; i++)
        printf("%0x ", bar[i]&0x00ff);
    printf("\n");

    // unsigned char bar = convert(foo, 16);
    // printf("%x", bar);
    // printf("%ld\n", atol("1ea1789cd57b3af8"));
    return 0;
}
