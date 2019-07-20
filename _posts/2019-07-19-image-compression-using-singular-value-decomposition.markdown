---
layout: post
title: "Image Compression with Singular Value Decomposition"
date: 2019-07-19 03:22:57 +0200
comments: true
categories: 
---

This blog-post is about compression of jpg files using SVD (Singular Value Decomposition). This is inspired from a project that I did with Ultra Wide-band Imaging. There, forming the observation matrix was very different where real life data from a linear array of synthetic aperture radar was given with a set of frequencies of operation (large bandwidth). There, forming the image was the real task with different bandwidths and different aperture sampling of the radar elements with some theoretical electromagnetic tools and SVD. 

Damn! That was a lot and not certainly required here. So, don't worry. Here, we will deal with only a static given image with a jpg format. The number of pixels are already defined. So, no change in that. Therefore, neither heavy electromagnetic equations nor huge matrix formations are required here. 

### Singular Value Decomposition (SVD)

A singular value decomposition says a lot about the observation matrix. The image is nothing but a 2D matrix filled with some data. And, a matrix A which is not a square matrix can be decomposed like the following way. 

$$
	A = U S V^H
$$


The dimensions are important here. If A is a $M \times N$ matrix, then U is a square matrix with dimensions $M \times M$, S is a Diagonal matrix with a dimension of $M \times N$ and V is a matrix with dimension of $N \times N$. Note: In my actual project with the data from the radar, U was called the data space because it had the dimension containing all the frequency samples for every antenna and V was called as the object space where it indicated the number of pixels. However, as this is a static image, the observation matrix A here is just the number of points in the row and column of the 2D matrix of that image. 

$$

A \Bigg(M\Bigg[^N \quad \Bigg]\Bigg) = U \Bigg(M\Bigg[^M \quad \Bigg]\Bigg) S \Bigg(M \Bigg[^N \quad \quad \Bigg]\Bigg) V \Bigg(N \Bigg[^N \quad \Bigg]\Bigg)^H

$$

### Singular Values

Singular values say a lot about the image. The matrix S that is shown above has all the singular values on its diagonal. One sample plot of the singular values is shown in figure below. This is normalized to the maximum value of the diagonal elements of S and plotted in a dB scale. Therefore, the maximum we see is 0 and the rest are negative values in dBs. 

$$
	20\log_{10}\Bigg(\frac{diag(S)}{max(diag(S))}\Bigg)
$$

<img src="/images/Singular_Values.png">

It can be seen that there are actually only a few number of singular values which are dominant and after some point, the values are really small and tend to 0. Sometimes, when it is a inverse problem of A (Not here), these almost zero values can cause problems. Therefore, in that case removing before doing an inverse is a wise thing to do. In this case however, with a TSVD (Truncated SVD) approach, we can just ignore the zero values in S and just keep the dominant values to recreate the image. Therefore, the image matrix or the observation matrix A can be written as the following with a TVSD approach.

$$
	A_{TVSD} = U(M \times T) S(T \times T) V(N \times T)^H
$$

From the above equation we notice that the final dimension of A is not affected. Here T is less than the usual number of singular values present. That is the reason it is called a TVSD approach. 

Then, if we rearrange this in a matrix, we can recreate the image. This time as less number of singular values are used, the file size is reduced. It can be seen from the singular value plots that already only 50 % of the data are dominant and rest are below -50 dB almost. 

### Results:

I tried with different number of singular values and the results are shown below. 



<img src="/images/outfile_337.jpg">
Image 1: The original image.



<img src="/images/outfile_5.jpg">
Image 2: With 5 % values in S.



<img src="/images/outfile_10.jpg">
Image 3: With 10 % values in S.



<img src="/images/outfile_30.jpg">
Image 4: With 30 % values in S.



<img src="/images/outfile_50.jpg">
Image 5: With 50 % values in S.



<img src="/images/outfile_70.jpg">
Image 6: With 70 % values in S.

It can already be seen that with only 50 % of the singular values, we get a very similar quality image which is not bad at all. And by doing this, we can save half of the size. Though the actual image was not that heavy, I have tried with 1 MB images and this approach with 50 % of the singular values reduced almost 40 % of the image size. 

### The Python Package that I made for this

The actual project with the radars I did with MATLAB. This time I wanted to do this one for fun and I wanted to learn how to make a command line tool as well. Therefore, I used the clint package to make my own command line tool.

#### Usage:

Install it via pip with the following command:

	pip install compressjpg


It installs the dependencies like `numpy` and `scipy`. 

After the successful installation one can use it like the following directly from the terminal:

	compress-jpg  -i input_file.jpg -o output_file.jpg -p <% Of truncation you want>

Where the flag -i means input and `-o` means output.

The option `-p` is optional. If you don't use it, it automatically does it with 50% truncation. I will try to do it with a better logic where it checks the dB values so that it can become immune to different images. 

It was a nice and fun thing to do during the holidays. In the process I learnt how to activate latex formatting on my octopress ruby blog. :P Furthermore, I learnt how to make a python package which I revised after 1.5 years. Happy hacking and give it a go if you want. :D







