#define EN0 0 /* MODE == encrypt */
#define DE1 1 /* MODE == decrypt */

typedef struct {
  unsigned long ek[32];
  unsigned long dk[32];
} des_ctx;

extern void deskey(unsigned char *, short);
/*                    hexkey[8]      MODE
 * Sets the internal key register according to the hexadecimal
 * key contained in the 8 bytes of hexkey, according to the DES,
 * for encryption and decryption according to MODE.
 */

extern void usekey(unsigned long *);
/*                  cookedkey[32]
 * Loads the internal key register with the data in cookedkey.
 */

extern void cpkey(unsigned long *);
/* Copies the contents of the internal key register into the storage
 * located at &cookedkey[0].
 */

extern void des(unsigned char *, unsigned char *);
/*                from[8]            to[8]
 * Encrypts/Decrypts (according to the key currently loaded in the
 * internal key register) one block of eight bytes at address 'from'
 * into the block at address 'to'. They can be the same.
*/

static void scrunch(unsigned char *, unsigned long *);
static void unscrun(unsigned long *, unsigned char *);
static void desfunc(unsigned long *, unsigned long *);
static void cookey(unsigned long *);

static unsigned long KnL[32] = {0L};
static unsigned long KnR[32] = {0L};
static unsigned long Kn3[32] = {0L};
static unsigned char Df_Key[24] = {
  0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef,
  0xfe, 0xdc, 0xba, 0x98, 0x76, 0x54, 0x32, 0x10,
  0x89, 0xab, 0xcd, 0xef, 0x01, 0x23, 0x45, 0x67};

static unsigned short bytebit[8] = {
  0200, 0100, 040, 020, 010, 04, 02, 01};

static unsigned long bigbyte[24] = {
  0x800000L, 0x400000L, 0x200000L, 0x100000L,
  0x80000L,  0x40000L,  0x20000L,  0x10000L,
  0x8000L,   0x4000L,   0x2000L,   0x1000L,
  0x800L,    0x400L,    0x200L,    0x100L,
  0x80L,     0x40L,     0x20L,     0x10L,
  0x8L,      0x4L,      0x2L,      0x1L};

/* Use the key schedule specified in the Standard (ANSI X3.92-1981). */

static unsigned char pc1[56] = {
  56, 48, 40, 32, 24, 16,  8,  0, 57, 49, 41, 33, 25, 17,
   9,  1, 58, 50, 42, 34, 26, 18, 10,  2, 59, 51, 43, 35,
  62, 54, 46, 38, 30, 22, 14,  6, 61, 53, 45, 37, 29, 21,
  13,  5, 60, 52, 44, 36, 28, 20, 12,  4, 27, 19, 11, 3};

static unsigned char totrot[16] = {
  1, 2, 4, 6, 8, 10, 12, 14, 15, 17, 19, 21, 23, 25, 27, 28};

static unsigned char pc2[48] = {
  13, 16, 10, 23,  0,  4,  2, 27, 14,  5, 20,  9,
  22, 18, 11,  3, 25,  7, 15,  6, 26, 19, 12,  1,
  40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47,
  43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 28, 31};
