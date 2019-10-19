import re
from math import floor

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

keyStruct = []
keyFile = open("keySteps.txt", 'r')
for line in keyFile:
    keyStruct.append(line[:-1].split(", "))

blockCounter = 0
outStr = ""
with open('encodeSteps.txt') as fp:
   line = True
   while line:
       line = fp.readline()
       dataIn = line[:-1]
       line = fp.readline()
       dataOut1 = line[:-1]
       line = fp.readline()
       dataOut2 = line[:-1]
       line = fp.readline()
       dataOut3 = line[:-1]
       line = fp.readline()

       key1 = keyStruct[floor(blockCounter/10)][0]
       key2 = keyStruct[floor(blockCounter/10)][1]
       key3 = keyStruct[floor(blockCounter/10)][2]
       thisOut = input2[:]
       thisOut = thisOut.replace("KEY1", key1)
       thisOut = thisOut.replace("KEY2", key2)
       thisOut = thisOut.replace("KEY3", key3)
       thisOut = thisOut.replace("DATAIN", dataIn)
       thisOut = thisOut.replace("DATAOUT1", dataOut1)
       thisOut = thisOut.replace("DATAOUT2", dataOut2)
       thisOut = thisOut.replace("DATAOUT3", dataOut3)
       outStr += thisOut
       blockCounter += 1



# target = 0
# with open('Key.txt') as k:
#     key = True
#     while key:
#         key1 = k.readline()
#         if key1 == "":
#             continue
#         key2 = k.readline()
#         key3 = k.readline()
#         with open('Plaintextin.txt') as p:
#             plaintext = True
#             while plaintext:
#                 plaintext = p.readline()
#                 if plaintext == "":
#                     continue
#                 target += 1
#                 counter = 0
#                 with open('Ciphertextout.txt') as c:
#                     ciphertext = True
#                     while ciphertext:
#                         ciphertext = c.readline()
#                         if ciphertext == "":
#                             continue
#                         counter += 1
#                         if counter == target:
#                             # print("key: " + key)
#                             # print("plaintext: " + plaintext)
#                             # print("ciphertext: " + ciphertext)
#                             newText = input2
#                             newText = re.sub('*KEY*', key[:-1], newText)
#                             newText = re.sub('*CIPHERTEXT*', ciphertext[:-1], newText)
#                             newText = re.sub('*PLAINTEXT*', plaintext[:-1], newText)
#                             outText += newText


outFile = open("vhdlOutput.txt", 'w')
outStr = input1 + outStr + input3
outFile.write(outStr)
#
# outfile.close()
