#include <stdio.h>
#include "des.h"
#include <string.h>
#include <stdlib.h>
// #include <assert.h>

void deskey(key, edf)
unsigned char *key;
short edf;
{
  register int i, j, l, m, n;
  unsigned char pc1m[56], pcr[56];
  unsigned long kn[32];

  for (j=0; j<56; j++) {
    l = pc1[j];
    m = l & 07;
    pc1m[j] = (key[l>>3] & bytebit[m]) ? 1 : 0;
  }

  for (i=0; i<16; i++) {
    if (edf==DE1)
      m = (15-i) << 1;
    else
      m = i << 1;
    n = m + 1;
    kn[m] = kn[n] = 0L;
    for (j=0; j<28; j++) {
      l = j + totrot[i];
      if (l<28)
        pcr[j] = pc1m[l];
      else
        pcr[j] = pc1m[l-28];
    }
    for (j=28; j<56; j++) {
      l = j + totrot[i];
      if (l<56)
        pcr[j] = pc1m[l];
      else
        pcr[j] = pc1m[l-28];
    }
    for (j=0; j<24; j++) {
      if (pcr[pc2[j]])
        kn[m] |= bigbyte[j];
      if (pcr[pc2[j+24]])
        kn[n] |= bigbyte[j];
    }
  }
  cookey(kn);
  return;
}

static void cookey(raw1)
register unsigned long *raw1;
{
  register unsigned long *cook, *raw0;
  unsigned long dough[32];
  register int i;

  cook = dough;
  for (i=0; i<16; i++, raw1++) {
    raw0 = raw1++;
    *cook    = (*raw0 & 0x00fc0000L) << 6;
    *cook   |= (*raw0 & 0x00000fc0L) << 10;
    *cook   |= (*raw1 & 0x00fc0000L) >> 10;
    *cook++ |= (*raw1 & 0x00000fc0L) >> 6;
    *cook    = (*raw0 & 0x0003f000L) << 12;
    *cook   |= (*raw0 & 0x0000003fL) << 16;
    *cook   |= (*raw1 & 0x0003f000L) >> 4;
    *cook++ |= (*raw1 & 0x0000003fL);
  }
  usekey(dough);
  return;
}

void cpkey(into)
register unsigned long *into;
{
  register unsigned long *from, *endp;

  from = KnL, endp = &KnL[32];
  while (from < endp)
    *into++ = *from++;
  return;
}

void usekey(from)
register unsigned long *from;
{
  register unsigned long *to, *endp;

  to = KnL, endp = &KnL[32];
  while (to < endp)
    *to++ = *from++;
  return;
}

void des(inblock, outblock)
unsigned char *inblock, *outblock;
{
  unsigned long work[2];

  scrunch(inblock, work);
  desfunc(work, KnL);
  unscrun(work, outblock);
  return;
}

static void scrunch(outof, into)
register unsigned char *outof;
register unsigned long *into;
{
  *into    = (*outof++ & 0xffL) << 24;
  *into   |= (*outof++ & 0xffL) << 16;
  *into   |= (*outof++ & 0xffL) << 8;
  *into++ |= (*outof++ & 0xffL);
  *into    = (*outof++ & 0xffL) << 24;
  *into   |= (*outof++ & 0xffL) << 16;
  *into   |= (*outof++ & 0xffL) << 8;
  *into   |= (*outof   & 0xffL);
  return;
}

static void unscrun(outof, into)
register unsigned long *outof;
register unsigned char *into;
{
  *into++ = (*outof >> 24) & 0xffL;
  *into++ = (*outof >> 16) & 0xffL;
  *into++ = (*outof >>  8) & 0xffL;
  *into++ = *outof++       & 0xffL;
  *into++ = (*outof >> 24) & 0xffL;
  *into++ = (*outof >> 16) & 0xffL;
  *into++ = (*outof >>  8) & 0xffL;
  *into   = *outof         & 0xffL;
  return;
}

static unsigned long SP1[64] = {
	0x01010400L, 0x00000000L, 0x00010000L, 0x01010404L,
	0x01010004L, 0x00010404L, 0x00000004L, 0x00010000L,
	0x00000400L, 0x01010400L, 0x01010404L, 0x00000400L,
	0x01000404L, 0x01010004L, 0x01000000L, 0x00000004L,
	0x00000404L, 0x01000400L, 0x01000400L, 0x00010400L,
	0x00010400L, 0x01010000L, 0x01010000L, 0x01000404L,
	0x00010004L, 0x01000004L, 0x01000004L, 0x00010004L,
	0x00000000L, 0x00000404L, 0x00010404L, 0x01000000L,
	0x00010000L, 0x01010404L, 0x00000004L, 0x01010000L,
	0x01010400L, 0x01000000L, 0x01000000L, 0x00000400L,
	0x01010004L, 0x00010000L, 0x00010400L, 0x01000004L,
	0x00000400L, 0x00000004L, 0x01000404L, 0x00010404L,
	0x01010404L, 0x00010004L, 0x01010000L, 0x01000404L,
	0x01000004L, 0x00000404L, 0x00010404L, 0x01010400L,
	0x00000404L, 0x01000400L, 0x01000400L, 0x00000000L,
	0x00010004L, 0x00010400L, 0x00000000L, 0x01010004L };

static unsigned long SP2[64] = {
	0x80108020L, 0x80008000L, 0x00008000L, 0x00108020L,
	0x00100000L, 0x00000020L, 0x80100020L, 0x80008020L,
	0x80000020L, 0x80108020L, 0x80108000L, 0x80000000L,
	0x80008000L, 0x00100000L, 0x00000020L, 0x80100020L,
	0x00108000L, 0x00100020L, 0x80008020L, 0x00000000L,
	0x80000000L, 0x00008000L, 0x00108020L, 0x80100000L,
	0x00100020L, 0x80000020L, 0x00000000L, 0x00108000L,
	0x00008020L, 0x80108000L, 0x80100000L, 0x00008020L,
	0x00000000L, 0x00108020L, 0x80100020L, 0x00100000L,
	0x80008020L, 0x80100000L, 0x80108000L, 0x00008000L,
	0x80100000L, 0x80008000L, 0x00000020L, 0x80108020L,
	0x00108020L, 0x00000020L, 0x00008000L, 0x80000000L,
	0x00008020L, 0x80108000L, 0x00100000L, 0x80000020L,
	0x00100020L, 0x80008020L, 0x80000020L, 0x00100020L,
	0x00108000L, 0x00000000L, 0x80008000L, 0x00008020L,
	0x80000000L, 0x80100020L, 0x80108020L, 0x00108000L };

static unsigned long SP3[64] = {
	0x00000208L, 0x08020200L, 0x00000000L, 0x08020008L,
	0x08000200L, 0x00000000L, 0x00020208L, 0x08000200L,
	0x00020008L, 0x08000008L, 0x08000008L, 0x00020000L,
	0x08020208L, 0x00020008L, 0x08020000L, 0x00000208L,
	0x08000000L, 0x00000008L, 0x08020200L, 0x00000200L,
	0x00020200L, 0x08020000L, 0x08020008L, 0x00020208L,
	0x08000208L, 0x00020200L, 0x00020000L, 0x08000208L,
	0x00000008L, 0x08020208L, 0x00000200L, 0x08000000L,
	0x08020200L, 0x08000000L, 0x00020008L, 0x00000208L,
	0x00020000L, 0x08020200L, 0x08000200L, 0x00000000L,
	0x00000200L, 0x00020008L, 0x08020208L, 0x08000200L,
	0x08000008L, 0x00000200L, 0x00000000L, 0x08020008L,
	0x08000208L, 0x00020000L, 0x08000000L, 0x08020208L,
	0x00000008L, 0x00020208L, 0x00020200L, 0x08000008L,
	0x08020000L, 0x08000208L, 0x00000208L, 0x08020000L,
	0x00020208L, 0x00000008L, 0x08020008L, 0x00020200L };

static unsigned long SP4[64] = {
	0x00802001L, 0x00002081L, 0x00002081L, 0x00000080L,
	0x00802080L, 0x00800081L, 0x00800001L, 0x00002001L,
	0x00000000L, 0x00802000L, 0x00802000L, 0x00802081L,
	0x00000081L, 0x00000000L, 0x00800080L, 0x00800001L,
	0x00000001L, 0x00002000L, 0x00800000L, 0x00802001L,
	0x00000080L, 0x00800000L, 0x00002001L, 0x00002080L,
	0x00800081L, 0x00000001L, 0x00002080L, 0x00800080L,
	0x00002000L, 0x00802080L, 0x00802081L, 0x00000081L,
	0x00800080L, 0x00800001L, 0x00802000L, 0x00802081L,
	0x00000081L, 0x00000000L, 0x00000000L, 0x00802000L,
	0x00002080L, 0x00800080L, 0x00800081L, 0x00000001L,
	0x00802001L, 0x00002081L, 0x00002081L, 0x00000080L,
	0x00802081L, 0x00000081L, 0x00000001L, 0x00002000L,
	0x00800001L, 0x00002001L, 0x00802080L, 0x00800081L,
	0x00002001L, 0x00002080L, 0x00800000L, 0x00802001L,
	0x00000080L, 0x00800000L, 0x00002000L, 0x00802080L };

static unsigned long SP5[64] = {
	0x00000100L, 0x02080100L, 0x02080000L, 0x42000100L,
	0x00080000L, 0x00000100L, 0x40000000L, 0x02080000L,
	0x40080100L, 0x00080000L, 0x02000100L, 0x40080100L,
	0x42000100L, 0x42080000L, 0x00080100L, 0x40000000L,
	0x02000000L, 0x40080000L, 0x40080000L, 0x00000000L,
	0x40000100L, 0x42080100L, 0x42080100L, 0x02000100L,
	0x42080000L, 0x40000100L, 0x00000000L, 0x42000000L,
	0x02080100L, 0x02000000L, 0x42000000L, 0x00080100L,
	0x00080000L, 0x42000100L, 0x00000100L, 0x02000000L,
	0x40000000L, 0x02080000L, 0x42000100L, 0x40080100L,
	0x02000100L, 0x40000000L, 0x42080000L, 0x02080100L,
	0x40080100L, 0x00000100L, 0x02000000L, 0x42080000L,
	0x42080100L, 0x00080100L, 0x42000000L, 0x42080100L,
	0x02080000L, 0x00000000L, 0x40080000L, 0x42000000L,
	0x00080100L, 0x02000100L, 0x40000100L, 0x00080000L,
	0x00000000L, 0x40080000L, 0x02080100L, 0x40000100L };

static unsigned long SP6[64] = {
	0x20000010L, 0x20400000L, 0x00004000L, 0x20404010L,
	0x20400000L, 0x00000010L, 0x20404010L, 0x00400000L,
	0x20004000L, 0x00404010L, 0x00400000L, 0x20000010L,
	0x00400010L, 0x20004000L, 0x20000000L, 0x00004010L,
	0x00000000L, 0x00400010L, 0x20004010L, 0x00004000L,
	0x00404000L, 0x20004010L, 0x00000010L, 0x20400010L,
	0x20400010L, 0x00000000L, 0x00404010L, 0x20404000L,
	0x00004010L, 0x00404000L, 0x20404000L, 0x20000000L,
	0x20004000L, 0x00000010L, 0x20400010L, 0x00404000L,
	0x20404010L, 0x00400000L, 0x00004010L, 0x20000010L,
	0x00400000L, 0x20004000L, 0x20000000L, 0x00004010L,
	0x20000010L, 0x20404010L, 0x00404000L, 0x20400000L,
	0x00404010L, 0x20404000L, 0x00000000L, 0x20400010L,
	0x00000010L, 0x00004000L, 0x20400000L, 0x00404010L,
	0x00004000L, 0x00400010L, 0x20004010L, 0x00000000L,
	0x20404000L, 0x20000000L, 0x00400010L, 0x20004010L };

static unsigned long SP7[64] = {
	0x00200000L, 0x04200002L, 0x04000802L, 0x00000000L,
	0x00000800L, 0x04000802L, 0x00200802L, 0x04200800L,
	0x04200802L, 0x00200000L, 0x00000000L, 0x04000002L,
	0x00000002L, 0x04000000L, 0x04200002L, 0x00000802L,
	0x04000800L, 0x00200802L, 0x00200002L, 0x04000800L,
	0x04000002L, 0x04200000L, 0x04200800L, 0x00200002L,
	0x04200000L, 0x00000800L, 0x00000802L, 0x04200802L,
	0x00200800L, 0x00000002L, 0x04000000L, 0x00200800L,
	0x04000000L, 0x00200800L, 0x00200000L, 0x04000802L,
	0x04000802L, 0x04200002L, 0x04200002L, 0x00000002L,
	0x00200002L, 0x04000000L, 0x04000800L, 0x00200000L,
	0x04200800L, 0x00000802L, 0x00200802L, 0x04200800L,
	0x00000802L, 0x04000002L, 0x04200802L, 0x04200000L,
	0x00200800L, 0x00000000L, 0x00000002L, 0x04200802L,
	0x00000000L, 0x00200802L, 0x04200000L, 0x00000800L,
	0x04000002L, 0x04000800L, 0x00000800L, 0x00200002L };

static unsigned long SP8[64] = {
	0x10001040L, 0x00001000L, 0x00040000L, 0x10041040L,
	0x10000000L, 0x10001040L, 0x00000040L, 0x10000000L,
	0x00040040L, 0x10040000L, 0x10041040L, 0x00041000L,
	0x10041000L, 0x00041040L, 0x00001000L, 0x00000040L,
	0x10040000L, 0x10000040L, 0x10001000L, 0x00001040L,
	0x00041000L, 0x00040040L, 0x10040040L, 0x10041000L,
	0x00001040L, 0x00000000L, 0x00000000L, 0x10040040L,
	0x10000040L, 0x10001000L, 0x00041040L, 0x00040000L,
	0x00041040L, 0x00040000L, 0x10041000L, 0x00001000L,
	0x00000040L, 0x10040040L, 0x00001000L, 0x00041040L,
	0x10001000L, 0x00000040L, 0x10000040L, 0x10040000L,
	0x10040040L, 0x10000000L, 0x00040000L, 0x10001040L,
	0x00000000L, 0x10041040L, 0x00040040L, 0x10000040L,
	0x10040000L, 0x10001000L, 0x10001040L, 0x00000000L,
	0x10041040L, 0x00041000L, 0x00041000L, 0x00001040L,
	0x00001040L, 0x00040040L, 0x10000000L, 0x10041000L };

static void desfunc(block, keys)
register unsigned long *block, *keys;
{
  register unsigned long fval, work, right, leftt;
  register int round;

  leftt = block[0];
  right = block[1];
  work = ((leftt>>4) ^ right) & 0x0f0f0f0fL;
  right ^= work;
  leftt ^= (work<<4);
  work = ((leftt>>16) ^ right) & 0x0000ffffL;
  right ^= work;
  leftt ^= (work<<16);
  work = ((right>>2) ^ leftt) & 0x33333333L;
  leftt ^= work;
  right ^= (work<<2);
  work = ((right>>8) ^ leftt) & 0x00ff00ffL;
  leftt ^= work;
  right ^= (work<<8);
  right = ((right<<1) | ((right>>31) & 1L)) & 0xffffffffL;
  work = (leftt ^ right) & 0xaaaaaaaaL;
  leftt ^= work;
  right ^= work;
  leftt = ((leftt<<1) | ((leftt>>31) & 1L)) & 0xffffffffL;

  for (round=0; round<8; round++) {
    work  = (right<<28) | (right>>4);
    work ^= *keys++;
    fval  = SP7[work       & 0x3fL];
    fval |= SP5[(work>> 8) & 0x3fL];
    fval |= SP3[(work>>16) & 0x3fL];
    fval |= SP1[(work>>24) & 0x3fL];
    work  = right ^ *keys++;
    fval |= SP8[work       & 0x3fL];
    fval |= SP6[(work>> 8) & 0x3fL];
    fval |= SP4[(work>>16) & 0x3fL];
    fval |= SP2[(work>>24) & 0x3fL];
    leftt ^= fval;
    work  = (leftt<<28) | (leftt>>4);
    work ^= *keys++;
    fval  = SP7[work       & 0x3fL];
    fval |= SP5[(work>> 8) & 0x3fL];
    fval |= SP3[(work>>16) & 0x3fL];
    fval |= SP1[(work>>24) & 0x3fL];
    work  = leftt ^ *keys++;
    fval |= SP8[work       & 0x3fL];
    fval |= SP6[(work>> 8) & 0x3fL];
    fval |= SP4[(work>>16) & 0x3fL];
    fval |= SP2[(work>>24) & 0x3fL];
    right ^= fval;
  }

  right = (right<<31) | (right>>1);
  work = (leftt ^ right) & 0xaaaaaaaaL;
  leftt ^= work;
  right ^= work;
  leftt = (leftt<<31) | (leftt>>1);
  work = ((leftt>>8) ^ right) & 0x00ff00ffL;
  right ^= work;
  leftt ^= (work<<8);
  work = ((leftt>>2) ^right) & 0x33333333L;
  right ^= work;
  leftt ^= (work<<2);
  work = ((right>>16) ^ leftt) & 0x0000ffffL;
  leftt ^= work;
  right ^= (work<<16);
  work = ((right>>4) ^ leftt) & 0x0f0f0f0fL;
  leftt ^= work;
  right ^= (work<<4);
  *block++ = right;
  *block = leftt;
  return;
}

/* Validation sets:
 *
 * Single-length key, single-length plaintext -
 * Key    : 0123 4567 89ab cdef
 * Plain  : 0123 4567 89ab cde7
 * Cipher : c957 4425 6a5e d31d
 *
 ******************************************************/

void des_key(des_ctx *dc, unsigned char *key) {
  deskey(key, EN0);
  cpkey(dc->ek);
  deskey(key, DE1);
  cpkey(dc->dk);
}

/* Encrypt several blocks in ECB mode. Caller is responsible for
   short blocks. */
void des_enc(des_ctx *dc, unsigned char *data, int blocks) {
  unsigned long work[2];
  int i;
  unsigned char *cp;

  cp = data;
  for (i=0; i<blocks; i++) {
    scrunch(cp, work);
    desfunc(work, dc->ek);
    unscrun(work, cp);
    cp += 8;
  }
}

void des_dec(des_ctx *dc, unsigned char *data, int blocks) {
  unsigned long work[2];
  int i;
  unsigned char *cp;

  cp = data;
  for (i=0; i<blocks; i++) {
    scrunch(cp, work);
    desfunc(work, dc->dk);
    unscrun(work, cp);
    cp += 8;
  }
}

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

// Note: all uncommented blocks of code are unchanged from the original
void main (void)
{
  des_ctx dc;
  int i;
  unsigned long data[10];

  // Leaving these uninitialized
  char *cp, key1[8], key2[8], key3[8];
  char x[8];
  char textHex[8];

  // I/O variable declarations for various output files
  //FILE *ciphertextOut;
  FILE *plaintextOut;
  int keyCounter = 0;
  //char ciphertextFileName[19] = "Ciphertextout0.txt";
  char plaintextFileName[18] = "Plaintextout0.txt";

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

  // Open key file
  keyPointer = fopen("Key.txt", "r");

  // Read Key.txt line-by-line
  while ((keyRead = getline(&keyLine, &keyLen, keyPointer)) != -1)
  {
      // Copy the contents of the current keyLine to key
      memcpy(key1, keyLine, sizeof(key1));

      keyRead = getline(&keyLine, &keyLen, keyPointer);
      memcpy(key2, keyLine, sizeof(key2));

      keyRead = getline(&keyLine, &keyLen, keyPointer);
      memcpy(key3, keyLine, sizeof(key3));

      // Print out the key
      printf("\nKey 1, 2, 3: ");
      for (i=0; i<sizeof(key1); i++)
      {
         printf("%0x", key1[i]);
      }
      printf(", ");
      for (i=0; i<sizeof(key2); i++)
      {
         printf("%0x", key2[i]);
      }
      printf(", ");
      for (i=0; i<sizeof(key3); i++)
      {
         printf("%0x", key3[i]);
      }
      printf("\n");

      // Open text file on every loop
      textPointer = fopen("Ciphertextin.txt", "r");

      // Increase keyCounter
      keyCounter = keyCounter + 1;

      // Open output files
      //ciphertextFileName[13] = keyCounter +'0';
      plaintextFileName[12] = keyCounter +'0';
      //ciphertextOut = fopen(ciphertextFileName, "a");
      plaintextOut = fopen(plaintextFileName, "a");

      // Read Ciphertextin.txt line-by-line
      while ((textRead = getline(&textLine, &textLen, textPointer)) != -1)
      {
          // Convert text line from a string of hex characters to an array of hex characters
          hexify(textLine, textHex);

          // Print output of hexify
         // printf("Hexify: ");
          for (int i=0; i<sizeof(textHex); i++)
          {
              printf("%0x", textHex[i]&0x00FF);
          }
          printf("\n");
          //printf("textLine: %s\n", textLine);


          // Copy the contents of the current textLine to x
          // memcpy(x, textLine, sizeof(x));
          memcpy(x, textHex, sizeof(x));

          // Print out the plaintext
          // printf("Text: ");
          // for (i=0; i<sizeof(x); i++)
          // {
          //    printf("%x", x[i]);
          // }
          // printf("\n");

          cp = x;

          des_key(&dc, key3);
          des_dec(&dc, cp, 1);

          //printf("Text: ");
          for (i=0; i<sizeof(cp); i++)
          {
             //printf("%02x", cp[i]);
             printf("%02x", ((unsigned int) cp[i])&0x00ff);
          }
          printf("\n");

          // printf("\n");
          // memcpy(x, textLine, sizeof(x));
          // cp = x;
          des_key(&dc, key2);
          des_dec(&dc, cp, 1);
          // Print out the plaintext
          //printf("Text: ");
          for (i=0; i<sizeof(cp); i++)
          {
             //printf("%02x", cp[i]);
             printf("%02x", ((unsigned int) cp[i])&0x00ff);
          }
          printf("\n");

          // // memcpy(x, textLine, sizeof(x));
          // // cp = x;
          des_key(&dc, key1);
          des_dec(&dc, cp, 1);
          // Print out the plaintext
          //printf("Text: ");
          for (i=0; i<sizeof(cp); i++)
          {
             //printf("%02x", cp[i]);
             printf("%02x", ((unsigned int) cp[i])&0x00ff);
          }
          printf("\n");

          // printf("Enc(0..7, 0..7) = ");
          // for (i=0; i<8; i++)
          // {
          //   printf("%02x ", ((unsigned int) cp[i])&0x00ff);
          //   //fprintf(ciphertextOut, "%02x", ((unsigned int)cp[i])&0x00ff);
          // }
          // printf("\n");

          //des_dec(&dc, cp, 1);

          // printf("Dec(above, 0..7) = ");
          // for (i=0; i<8; i++)
          // {
          //   // Print to console and file
          //   printf("%c ", ((unsigned int)cp[i])&0x00ff);
          //   fprintf(plaintextOut, "%c", ((unsigned int)cp[i])&0x00ff);
          // }
          printf("\n");

          // Append a line break to both output files
          //fprintf(ciphertextOut, "\n");
          fprintf(plaintextOut, "\n");
      }
      // Close input file and output files on every loop
      fclose(textPointer);
      //fclose(ciphertextOut);
      fclose(plaintextOut);

  }
  // Close Key file
  fclose(keyPointer);

}
