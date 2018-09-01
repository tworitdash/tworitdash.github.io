---
layout: post
title: "Compiling Anything from the Portstree failed in FreeBSD 10.1 Raspberry Pi"
date: 2015-08-04 13:39:38 +0530
comments: true
categories: 
---
After getting portsnap extracted on my FreeBSD RPi Desktop, I wanted to compile a couple of things from the ports tree. But when I wanted to compile something, It first used to fetch "pkg" and the make failed. When I ran:

	# pkg updtae

It first used to ask to install the package manager. Then it used to terminate and instruct to install pkg from /usr/ports/ports-mgmt/pkg . But that procedure also failed with the same error messages that I had got while compiling nano nad links from ports tree. I found out a simple but effective solution to this.

	# whereis portmaster
	portmaster: /usr/ports/ports-mgmt/portmaster/
	# cd /usr/ports/ports-mgmt/portmaster && make install clean

Compiling portmaster was very time taking but it solved the issue and the pkg was successfully installed. Unfortunately I found no packagesite repositiry for "pkg update" online for FreeBSD:10.1:armv6 Release for Raspberry Pi. So, I couldn't use the pkg tool to install packages. And I tried to compile packages from the ports tree by hand. The processor and RAM of Raspberry Pi cause problem while compiling. It even takes one whole day or more than that to compile a package from the ports tree.

