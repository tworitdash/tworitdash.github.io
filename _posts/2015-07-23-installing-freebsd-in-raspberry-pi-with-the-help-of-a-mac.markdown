---
layout: post
title: "Installing FreeBSD in Raspberry Pi with the help of a Mac"
date: 2015-07-23 10:38:13 +0530
comments: true
categories: 
---
I have a Raspberry Pi B+ model. After running FreeBSD for about a month in the VirtualBox application in my Macbook Pro, I wished to have it installed natively somewhere else. Then I thought not to use a huge system or computer. I just needed a few space to run a server in a jail. Then, I happened to notice that my Raspberry Pi had not been used for ages. I had further plans to have a RFID security system using FreeBSD jails to configure the server to use it as a IoT (Internet of Things) project. Then, I arranged a HDMI cable, a USB keyboard, a 16 GB SD card from Samsung and a USB WiFi module (Netgear Adaptor). 

So, let's get started.

First connect the SD card to mac. Then open up the terminal and type
	
	df -h

or

	diskutil list

From the above commands, you can see your SD card volume as /dev/diskn. Where n is 2, 3 or something of that sort. And from the first command u can see a partition of that same as /dev/diskns1 or something like that. Now, we need to unmount that partition to start loading the image. 

	sudo diskutil umount /dev/diskns1

After getting the unmounted message, download the FreeBSD archive required for Raspberry Pi from the FreeBSD website. I downloaded it from [here](ftp://ftp.freebsd.org/pub/FreeBSD/releases/arm/armv6/ISO-IMAGES/10.1/) , from the ftp site. Then, double click on that archive to get the image file of the OS. Let it be in the Downloads folder. Then,

	cd ~/Downloads
	sudo dd if=your_image_file.img of=/dev/rdiskn bs=1m

It will take sometime to write the image on to the SD card. Before running this command, do know what it means. "if" stands for input file. "of" stands for output file. And make sure to write rdiskn instead of diskn. This will write the image in a raw disk format and the process will be faster. And, the other difference that I have marked is that, if one is using diskn in stead of rdiskn, after writing the disk space created will not be visible. If you insert it again, you will find a message of incompatibility. Then you will end up formatting your disk once again. And make sure that diskn is really your SD card. Otherwise, you will end up destroying your mac. 

After writing the image, you can see the disk space in finder. Click on it to see inside. Then a few things need to be replaced in the disk. The bootcode.bin and the start.elf need to be replaced. Go [here](https://github.com/raspberrypi/firmware/tree/master/boot) to find the the above mentioned files and replace them in the disk.

Then eject the SD card and put in your Pi. Connect the HDMI cable to the Pi and to a monitor. Connect a USB keyboard as well. Then power up your Pi. 

Voila !! It's working.

P.S. - If it doesn't work, go to the firmware github page once again and fetch all the **fixup and start** files and replace them in the disk (SD card) and don't destroy your mac. It's pretty expensive. :P     