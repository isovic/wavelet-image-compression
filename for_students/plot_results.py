#! /usr/bin/python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import Image

def LoadImage(imagePath, imageWidth, imageHeight):
	try:
		fp = open(imagePath, 'r');
		lines = fp.readlines();
		fp.close();
	except IOError:
		print 'ERROR: Could not open file "%s" for reading! Exiting.' % imagePath;
		exit(1);
	
	retImage = [int(line.strip()) for line in lines];
	retImage = np.array(retImage);
	retImage = np.reshape(retImage, (imageWidth, imageHeight));

	return retImage;

def CompressImage(originalImage, imageWidth, imageHeight, threshold):
	retData = [];
	
	thresheldImage = ThresholdImage(originalImage, imageWidth, imageHeight, threshold);
	
	numZero = 0;
	totalLength = 0;
	
	i = 0;
	j = 0;
	while i < imageHeight:
		j = 0;
		while j < imageWidth:
			if numZero < 255 and originalImage[i][j] == 0:
				numZero += 1;
			else:
				retData.append(numZero);
				retData.append(originalImage[i][j]);
				numZero = 0;
				totalLength += (numZero + 1);
			j += 1;
		i += 1;
	
	if (totalLength < (imageWidth * imageHeight)):
		print 'Remaining data...';
		
		if numZero > 0:
			retData.append((numZero - 1));
			retData.append(originalImage[-1][-1]);
		else:
			retData.append(numZero);
			retData.append(originalImage[-1][-1]);
			
	return retData;

def LoadCompressed(imagePath, imageWidth, imageHeight):
	try:
		fp = open(imagePath, 'r');
		lines = fp.readlines();
		fp.close();

	except IOError:
		print 'ERROR: Could not open file "%s" for reading! Exiting.' % imagePath;
		exit(1);
	
	retNumBytes = len(lines);
	
	numImageLines = (imageWidth / 2) * (imageHeight / 2);
	
	imageLL = np.zeros((imageWidth/2, imageHeight/2));
	imageLH = np.zeros(numImageLines);
	imageHL = np.zeros(numImageLines);
	imageHH = np.zeros(numImageLines);
	
	retImage = np.zeros((imageWidth, imageHeight));
	
	linesLL = lines[0:numImageLines];
	imageLL = [int(line.strip()) for line in linesLL];
	imageLL = np.array(imageLL);
	imageLL = np.reshape(imageLL, (imageWidth/2, imageHeight/2));
	
	currentPixel = 0;
	currentComponent = 0;
	i = numImageLines;
	while i < len(lines):
		numZeros = int(lines[i + 0]);
		pixelValue = int(lines[i + 1]);

		currentPixel += numZeros;
		
		if currentComponent == 0:
			imageLH[currentPixel] = pixelValue;
		elif currentComponent == 1:
			imageHL[currentPixel] = pixelValue;
		elif currentComponent == 2:
			imageHH[currentPixel] = pixelValue;
		
		currentPixel += 1;
		
		if currentPixel >= numImageLines:
			currentPixel = 0;
			currentComponent += 1;

		if currentComponent > 2:
			break;
		
		i += 2;

	imageLH = np.reshape(imageLH, (imageWidth/2, imageHeight/2));
	imageHL = np.reshape(imageHL, (imageWidth/2, imageHeight/2));
	imageHH = np.reshape(imageHH, (imageWidth/2, imageHeight/2));
	
	i = 0;
	j = 0;
	while i < (imageHeight/2):
		j = 0;
		
		while j < (imageWidth/2):
			retImage[i][j] = imageLL[i][j];
			retImage[i + imageHeight/2][j] = imageHL[i][j];
			retImage[i][j + imageWidth/2] = imageLH[i][j];
			retImage[i + imageHeight/2][j + imageWidth/2] = imageHH[i][j];
			
			j += 1;
		i += 1;
		
	return [imageLL, imageLH, imageHL, imageHH, retImage, retNumBytes];
	
imageWidth = 256;
imageHeight = 256;
threshold = 10;

imageOriginal = LoadImage('data/lena256bw.txt', imageWidth, imageHeight);

[imageLL, imageLH, imageHL, imageHH, imageComplete, compressedNumBytes] = LoadCompressed('data/compressed.out', 256, 256);
originalNumBytes = 256 * 256;

print 'Original image: number of bytes = %d' % originalNumBytes;
print 'Compressed image: number of bytes = %d' % compressedNumBytes;
print 'Compression ratio: %.2f%%' % ((float(compressedNumBytes) / float(originalNumBytes)) * 100.0);
print ' ';



plt.subplot(2, 2, 1);
plt.imshow(imageLL, cmap = cm.Greys_r);

plt.subplot(2, 2, 2);
plt.imshow(imageLH, cmap = cm.Greys_r);

plt.subplot(2, 2, 3);
plt.imshow(imageHL, cmap = cm.Greys_r);

plt.subplot(2, 2, 4);
plt.imshow(imageHH, cmap = cm.Greys_r);

plt.show()
