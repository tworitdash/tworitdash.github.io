---
layout: post
title: "Atom Bot With ARM Cortex M4"
date: 2014-09-23 16:39:19 +0530
comments: true
categories: 
---
This is a new version of my atom-bot and I have used an ARM Cortex M4 (tm4c123g) microcontroller board.

The microcontroller has a clock speed of 80Mhz and it is a bit difficult to write code for it(as far as Arduino is concerned).

It is [edx](http://edx.org/), from which I learned how to use a texas ARM board. During the course, I got a sample code for the UART functions (universal asynchronous receiver and transmitter). And I modified it a bit for the tasks of my atom-bot. 

The difficulty was with the OS. I love to work on linux, but to burn a program to the ARM, one has to use windows. So whenever I needed a modification in the microcontroller task, I had to switch on to windows :( . And my windows system is damn slow. Believe me, after using it for 2 or 3 days, you will probably prefer to die instead. 

After burning the program to the microcontroller, it was easy for me to send serial commands from the raspberry pi. :) :) (Now everything can be done from any OS). And for obviuos reasons I used ubuntu for making a ssh connection to the raspberry pi and pi does its work from raspbian(debian for raspberry).

For obvious reasons :P !!! because I don't have a mac. :(

As mentioned in my first atom-bot blog, the ruby machine client is in the raspberry pi. And this machine client connects to the server and draws the commands that the browser client sends through websockets.

 

The codes are here 

[atom-bot-with-arm-cortex](http://github.com/tworitdash/atom-bot-with-arm-cortex/)

[Keil](http://keil.com/) is the IDE for the TIVA tm4c123g microcontroller. :)  :) 