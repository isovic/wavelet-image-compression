#! /usr/bin/python

import Image

img = Image.open('data/lena256bw.png');
[width, height] = img.size;
im = img.load();


fileBytes = [];

i = 0;
while i < height:
	j = 0;
	while j < width:
		fileBytes.append(im[j, i][0]);
		
		j += 1;
	i += 1;


fp = open('data/lena256bw.bin', 'wb');
newFileByteArray = bytearray(fileBytes)
fp.write(newFileByteArray);
fp.close();

fp = open('data/lena256bw.txt', 'w');
for value in fileBytes:
	fp.write('{0:08b}'.format(value) + '\n');
fp.close();
