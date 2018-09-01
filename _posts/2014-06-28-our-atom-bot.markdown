---
layout: post
title: "Our Atom Bot"
date: 2014-06-28 00:41:44 +0530
comments: true
categories: 
---
The name is inspired from [Real Steel](http://realsteel.wikia.com/wiki/Atom). This is just a prototype made using ruby libraries, [arduino microcontroller](http://www.arduino.cc/) board and [raspberry pi](http://www.raspberrypi.org/). The idea is to control a system or hardware from anywhere around the globe by the help of internet. What are actually the ruby libraries and how do those help?

The concept is based on web-socket server. The server accepts websocket connections on some port (let it be 8080). The server is written by the help of em-websocket ruby. Clients are connected to it by opening the websocket connections at the same port. And as soon as a client is connected, it gets associated with a channel(internal channel). And when a client sends a message, it's pushed to that channel and after that the same message can be sent to all connected clients.

## PING PONG

The ping-pong is the concept of receiving and sending messages. The browser clients are supported by the new versions of some browsers. In the javascript of that html page, we can connect to the server at the same port(8080). And it is then associated with callbacks like when a connection is made, when a new message is received and when the connection is closed. The messages here can be sent by clicking some buttons on that html page. Then along with the browser client, we can connect another client to the same channel which can receive the same message being sent by the browser client. How to send the same message to the serialport?

## SerialPort

Here comes another ruby gem called the [serialport](https://rubygems.org/gems/serialport). This gem is built to use RS-232 serialports. In the client code we can also create a object of serialport. And by the help of that object we can send that same message(here it's only a single character like 'a') to the serialport. So now the other client can receive the message from the browser client through the websocket channel and send that to the serialport. Why to send that message (character) to the serialport?

## Arduino

[Arduino](http://www.arduino.cc/) is a microcontroller board which has UART (universal asynchronous receiver and transmitter). This UART helps that board to receive the commands coming to it over the serialport. After getting the command(the command I am referring here is a character constant like 'a'), it can process the output accordingly. How can it know what to perform while that exact command is received? It can all be written in the Arduino IDE and  uploaded to that board to do the required tasks. Isn't that awesome? Arduino has IO ports and with the help of those anything at the output can be connected. 

## RaspberryPi

[RaspberryPi](http://www.raspberrypi.org/) is a credit-card sized computer (linux based) which can be easily connected to the arduino through its serialport(USB) and it can be connected to the internet over wifi. This can be the device in which the client code can be executed. :) :)

## A Prototype

We have made a prototype using the above libraries and the set of hardwares. We have connected  arduino with the pi through its serialport. And to the output of arduino, we have connected two motors (the motors are connected to two wheels) with a motor driver circuit. And now whenever we connect to the browser client we get a connection established. After that when the client is connected from the pi we can get our things done by clicking the buttons on that web-page. Along with that, in the browser client(in the javascript) we have included the code for accelerometer. Through this feature we can connect to the browser client with some device, having the accelerometer feature, and we can send messages to the other client by only tilting the device like a game. Isn't that fun? 

<iframe src="//player.vimeo.com/video/98682460" width="500" height="375" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="http://vimeo.com/98682460">MOV_0089.mp4</a> from <a href="http://vimeo.com/user29276136">Tworit</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

<img src="{{ root_url }}/images/atom.jpg">


The source-code :


[atom-bot](https://github.com/sunu/atom-bot)


## Utility

This system can help us in many ways like

	1. We can automate our home like we can turn on our oven just before reaching home or we can check if the door is locked or not.
	2. Security notifications can be sent as a app notification over the internet.
	3. Can be used in hospitals and in traffic systems

And a lot of things can be developed with this. :)