---
layout: post
title: "Raspberry Pi FreeBSD portsnap fetch clockktime Error"
date: 2015-08-04 13:29:54 +0530
comments: true
categories: 
---
After setting up the network, let's try to fetch and extract the portsnap. Hell !! It resulted in something irritating. 

	# portsnap fetch
	Looking up portsnap.FreeBSD.org mirrors... 2 mirrors found.
	Fetching snapshot tag from portsnap1.FreeBSD.org... done.
	Snapshot appears to have been created more than one day into the future!
	(Is the system clock correct?)
	Cowardly refusing to proceed any further.

This can be solved by using the proper timezone.

	vi /etc/rc.conf 

And add the following:

	ntpdate_enable="YES"

Then set up your timezone by the following command:

	# tzsetup

Then after a reboot, the fetch will work. :)

	# portsnap fetch extract
