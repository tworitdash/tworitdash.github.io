---
layout: post
title: "DFT using basic Python and Numpy"
date: 2014-11-15 23:45:49 +0530
comments: true
categories: 
---
There are several in-built functions for finding out DFT in Numpy Python. But still for fun, I have tried something on my own using basic Pyhton and Numpy to obtain the DFT of a sequence of a signal given in the form of an array like [0,1,2,3].

There are 3 inputs 
	1. The "N" in N point DFT
	2. The maximum number of data in the input array
	3. The elements of the array

To run this file you should have python installed in your system with the [numpy](http://www.scipy.org/scipylib/download.html) library.

Then get my code from here [dft.py](https://github.com/tworitdash/dft.py) either by downloading the zip file from the bottom right section of the web page or by cloning the repository if you have git (git bash in windows system):
	
	git clone https://github.com/tworitdash/dft.py

Then run that file in the terminal or command line :

	$ cd dft.py
	$ python dft.py

Sorry I have named the repository and the python file within it, with the same name called dft.py :P .
 

Sample output :
<img src="{{ root_url }}/images/dftout1.png">

This one is for N > the number of data in the array :

<img src="{{ root_url }}/images/dftout2.png">

And have fun !!! :) :)  