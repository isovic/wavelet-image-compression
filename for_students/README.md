This folder contains two scripts for preparing data and rapid testing of obtained results, and a sample input image (a greyscale image of Lena, placed in the data folder).
The scripts are:

1. image_convert.py
Converts the sample input image into an array of bytes (stored in ASCII format) in the same data folder. This file can then be loaded using VHDL's file loading function for RAM initialization.

2. plot_results.py
Loads and plots the compressed image from 'data/compressed.out' file. The file should be obtained from the simulation (or otherwise from the syntesized component).

The description of data format expected in 'data/compressed.out':
Normally, after wavelet decomposition, 4 components of the image are given: the approximation image (the one that passed through two low-pass filters (LL)), and three detail components (LH, HL and HH).
The LL component contains the majority of information, and is not compressed. If the image size iz WxH, then the size of the LL components if (W/2)x(H/2).

The rest 3 components are compressed by counting values that are lower than a given threshold, and storing the information as 2 bytes.
The first byte is the count of consecutive pixels that have values below the threshold, followed by a byte that contains the actuall value of the pixel that follows them.
For an example, consider the following array of values:
0 1 2 1 0 1 2 2 2 0 15 1 0 12
The compressed instance of this array would be (for a threshold of value 10):
10 15 2 12
This would read as: 10 zero values (or values below the threshold 10), followed by a value 15, followed by 2 zero values, followed by a value of 12.

The 'data/compressed.out' contains the following information:
(1) array of exact pixel values of the LL component. There are in total (W/2)x(H/2) data bytes stored. For example, if the original image was 256x256 pixels of resolution, then LL component would have 16384 bytes.
(2) array of compressed values for the LH component. The count of values is not given, but can be obtained implicitly by counting the bytes (i.e. the first byte in the pair denotes the number of zero values, while the second one denotes one single value. Thus the count for one pair should be (num_zero_values + 1). This should be repeated for all pairs). Once the count exceeds 16384, the portion of image corresponding to LH has been read.
(3) array of compressed values for the HL component (same as in (2)).
(4) array of compressed values for the HH component (same as in (2)).

