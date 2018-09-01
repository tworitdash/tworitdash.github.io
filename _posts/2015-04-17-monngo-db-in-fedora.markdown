---
layout: post
title: "Monngo DB in Fedora"
date: 2015-04-17 21:22:17 +0530
comments: true
categories: 
---

It is somewhat difficult to run mongo db by following the conventional steps for installing it in fedora. While starting mongo db, the normal problem that is usually encountered after authenticating is 

	$ systemctl start mongod
   
	$ starting mongod (via systemctl):  Job failed. See system journal and 'systemctl status' for details.  [FAILED]

And it is usualy found that the mongod.log is empty or rather absent. If one of the commands mongo or mongod is not working, then also the installation is incomplete becasue the mongo db server satrts with mongod and, if it is not working properly, it will be difficult to connect mongo clients to it even after providing correct authentication for the user.

It is also usually seen that the command /usr/bin/mongod or the archive /usr/share/man/man1/mongod.1.gz is not present.


## Installing Mongo DB in Fedora

First we have to remove the installed versions (if there is any).

	$ sudo su
	# yum erase mongodb
	# yum erase mongo-10gen
	# yum --disablerepo= * --enablerepo=fedora,updates install mongodb mongodb-server


Running Mongo

	# systemctl start mongod.service
  

Verifying 

 	# systemctl status mongod.service
 	# tail /var/log/mongodb/mongodb.log
 	# nmap -p27017 localhost

Because the default port for mongo db is 27017.

Running mongo clinet

 	#mongo

Starting mongo db each time you boot.
 
 	#systemctl enable mongod.service


Happy Hacking. :)
