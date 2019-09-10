import re

outfile = open('output.txt', 'w')
outText = ""

input1 = ""
with open('input1.txt') as fp:
   line = True
   while line:
       line = fp.readline()
       input1 += line
# print(input1)

input2 = ""
with open('input2.txt') as fp:
   line = True
   while line:
       line = fp.readline()
       input2 += line

input3 = ""
with open('input3.txt') as fp:
   line = True
   while line:
       line = fp.readline()
       input3 += line

with open('Key.txt') as k:
    key = True
    while key:
        key = k.readline()
        if key == "":
            continue
        with open('Plaintextin.txt') as p:
            plaintext = True
            while plaintext:
                plaintext = p.readline()
                if plaintext == "":
                    continue
                for i in range(1,6):
                    with open('Ciphertextout' + str(i) + '.txt') as c:
                        ciphertext = True
                        while ciphertext:
                            ciphertext = c.readline()
                            if ciphertext == "":
                                continue
                            # print("key: " + key)
                            # print("plaintext: " + plaintext)
                            # print("ciphertext: " + ciphertext)
                            newText = input2
                            newText = re.sub('1KEY1', key[:-1], newText)
                            newText = re.sub('1CIPHERTEXT1', ciphertext[:-1], newText)
                            newText = re.sub('1PLAINTEXT1', plaintext[:-1], newText)
                            outText += newText
outText = input1 + outText + input3
outfile.write(outText)

outfile.close()
