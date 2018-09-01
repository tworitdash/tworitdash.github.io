---
layout: post
title: "Configuring WiFi Adapter in FreeBSD Raspberry Pi"
date: 2015-08-04 12:44:40 +0530
comments: true
categories: 
---
After banging my head a lot of times, finally I found out the solution for connecting my Raspberry Pi to my WiFi network using an adapter. The adapter is from NetGear (realtek RTL IEEE 802.11) and while my machine used to boot up, it was recognized as "urtwn0" WiFi card. At first, the adopter didn't glow. Then I found out that is a problem adapter. So, I had to allow the license for realtek urtwn0 driver in /boot/loader.conf file. The file didn't exist and I created one.

	vi /boot/loader.conf

Then write the following lines into it.

	legal.realtek.license_ack=1
	if_urtwn_load="YES"

I know editing the FreeBSD files using vi is a pain. You can use ee editor also. If you have connected the Pi before with some wired network and installed nano in it, you can also use the nano editor to edit. It is pretty smooth. Then, reboot your system.

	reboot

After a reboot we are ready to create a network interface using wlan0.

	ifconfig

It will show the listed cards with the IPs assigned to them. You can find no inet address for "urtwn0" driver. 

	ifconfig wlan0 create wlandev urtwn0

It will create an interface wlan0 and the command will return the ethernet address. If you are getting the address without any error, you are ready to go. To permanently store the configuration, we have to add some line to /etc/rc.conf .

	vi /etc/rc.conf

The lines to be added are:

	wlans_urtwn0="wlan0"
	ifconfig_wlan0="WPA DHCP"

If you are having some difficulties while deleting characters in vi, just use <code>ESC</code> then <code>d</code> then left arrow button. Accordingly you can get how to delete multiple characters. Then <code>ESC</code> and <code>i</code> can help you edit the file again. 

Then to get to know about the list of WiFi networks:

	ifconfig wlan0 up scan

To connect to your network, you should edit the following file.

	vi /etc/wpa_supplicant.conf

And write the following lines as per your WiFi SSID and Password.

	network={
		ssid="your_ssid"
		psk="your_password"
	}

Then after a reboot, you can see the adapter glowing and you can check the IP by ifconfig.

Checking your network is also easy. Just look at the content of your resolv.conf file.

	cat /etc/resolv.conf

Then ping it. Like in my case:

	ping 192.168.43.1

And you will get 0% packet loss after terminating.

Happy Hacking ! :)
