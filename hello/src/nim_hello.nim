import nimcrypto
import std/base64

var aliceKey = "<key>"
var aliceData = "<data>"

var aliceIv: array[aes256.sizeBlock, byte] = [
     0xc3, 0x06, 0x9f, 0xfa, 0x8b, 0xfd, 0x68, 0x86, 0x8f, 0x1a, 0xbb, 0xd2, 0xa2, 0xab, 0x07, 0x35 
  ]

proc toString(bytes: openarray[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

const buffer_size = aes256.sizeBlock * 8

var ectx, dctx: CBC[aes256]
var key: array[aes256.sizeKey, byte]
var iv: array[aes256.sizeBlock, byte]
var plainText: array[buffer_size, byte]
var encText: array[buffer_size, byte]
var decText: array[buffer_size, byte]



var otro: array[buffer_size, byte]


var ptrKey = cast[ptr byte](addr key[0])
var ptrEncText = cast[ptr byte](addr encText[0])

var ptrIv = cast[ptr byte](addr iv[0])
let dataLen = uint(len(plainText))

let messageLen = len(aliceData)

let paddingBytesAmount = aes256.sizeBlock - (messageLen mod aes256.sizeBlock);

copyMem(addr plainText[0], addr aliceData[0], len(aliceData))

copyMem(addr key[0], addr aliceKey[0], len(aliceKey))

copyMem(addr iv[0], addr aliceIv[0], len(aliceIv))

copyMem(addr otro[0], addr plainText[0], len(aliceData))


for i in messageLen..((buffer_size)-1):
  otro[i] = cast[byte](paddingBytesAmount)

var ptrPlainText2 = cast[ptr byte](addr otro[0])

ectx.init(ptrKey, ptrIv)

ectx.encrypt(ptrPlainText2, ptrEncText, dataLen)

ectx.clear()

echo ""
echo "ENCRYPTED TEXT:", encode(encText)
echo ""

var ptrDecText = cast[ptr byte](addr decText[0])

  # Initialization of CBC[aes256] context with encryption key
dctx.init(ptrKey, ptrIv)
# Decryption process
dctx.decrypt(ptrEncText, ptrDecText, dataLen)
# Clear context of CBC[aes256]
dctx.clear()

echo ""
echo "DECRYPTED TEXT:", toString(decText)
echo ""