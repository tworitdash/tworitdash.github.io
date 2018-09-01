---
layout: post
title: "Blogging with Octopress and deploying in Github"
date: 2014-06-24 22:58:00 +0530
comments: true
categories: 
---
After a long and tiring hot day, finally it's raining here at Bhubaneswar. So let's hack some codes to make an awesome blogging site.


Do you feel the same as I feel about wordpress? If yes, then just get rid of it and use one of the best static page or blogging page generators called Octopress.And github provides an awesome online page generating option so that the codes can be pushed or deployed in github to share it on the web. :)

Steps:
Install ruby in your system (as octopress is based on ruby)

[For windows](http://www.tutorialspoint.com/ruby/ruby_installation_windows.htm)

[For ubtntu/debian](http://www.sdjournal.com/posts/ruby-with-rbenv-on-debian.html)

Using rbenv for ruby version and gem management is better in debian based operarting systems.

For mac users, there is no need to install ruby perhaps as they have it pre-installed.

Check by running either of the following.

	1. ruby -v
	2. ruby --version

Now we are ready to go for the hack.Let's make a folder and clone the octopress github repo in that.You will need the [git command line or the git bash](http://git-scm.com/download/win) for that in windows and for ubuntu or debian just <code>sudo apt-get install git</code> will do that same job.

	1. mkdir your_repo
	2. cd your_repo
	3. git clone git://github.com/imathis/octopress.git octopress
	4. cd octopress

Now we are in the octopress directory and now we need to install all the ruby gems to perform our task. So we first need the bundler gem.

	1. gem install bundler

Not <code>sudo gem install bundler</code> as we are using rbenv for ruby.

Then while in that directory run

	1. bundle install
	2. bundle exec rake install

The rake install command follows the rake task (install) and creates a group of files and folders in that octopress directory like <code>source</code> <code>public</code> etc and if you look into the source folder you can find the folder <code>_posts</code>(where all the blog markdown files are going to be saved).

Then for the basic configurations, open up the _config.yml file and set the things in that like ;

	1. url: http://yoursite.com
	2. title: My First Dummy Blog
	3. subtitle: 
	4. author: Me 
	5. simple_search: https://www.google.com/search
	6. description: whatever !

All set !!! :)

Then let's create the first blog 

	1. bundle exec rake new_post["your blog title"]

This rake task will create a markdown file in the <code>_posts</code> folder with the current date (/blog/year-month-date-title) as we see in general blogging sites.Open that file and you can see the page layout is "post" and I will explain how to make our own custom ones in my following blogs. 
	---
	1. 	layout: post
	2.	title: "Blogging with Octopress and deploying in Github"
	3.	date: 2014-06-24 22:58:00 +0530
	4.	comments: false
	5.	categories:
	----

Then insert your blog right below the - - - and save the file.

After that we can see the changes by running 

	1. bundle exec rake generate
	2. bundle exec rake preview

The preview task will create the page at port 4000 and to have a overview we can see it at <code>localhost:4000</code> in any browser.

Then stop that browser by running <code>ctrl+c</code> and we are done.

<p><h2> Deploying in Github </h2></p>
First we need to make a github account and make it verified through the email address(this has to be done to make github free pages live on the web).

Then we have to create a repo named <code>[username.github.io]</code>

Then we have to run the following in CLI or Terminal.

	1. bundle exec rake setup_github_pages

It will ask for the github repo link and we have to write the url for that github repo.

Then just deploy the codes.

	1. bundle exec rake deploy

In this task the static pages that are generated in the <code>rake generate </code> command will be copied from the <code>public</code> folder to the <code>_deploy</code> folder and at the same time the codes will be pushed to the master branch of that github repo. It will ask your github user and password and after that it will be all done. Then refresh that repo and all the codes will be there. \o/

Then wait for 15 minutes and then open <code>username.github.io</code> and you will have your blog on the web.

Still not satisfied ?? Want to get rid of the <code>github.io</code> from your url?? Do you have your custom domain ?? If the answers to all of the above questions are yes,yes and yes then follow the steps below.

<p><h2> Custom Domain </p></h2>

Adding a CNAME file in the source directory will do the job.
. 
	1. touch CNAME

Then open that file in any editor and add the url of your site.

	1. your_url.com



Then generate and deploy the codes and wait for 10 minutes. Then go to the github repo's right hand settings bar and scroll down a bit and you will be able to see in the github pages table the url of your site. [Your site is published at your_url.com] 


Then go to your service provider or domain provider link and create a new A record in the "DNS manage" and come back to your CLI or Terminal and run the following.

	1. dig username.github.io +nostats +nocomments +nocmd

Then it will show up something like this.

	
	1. github.map.fastly.net.	17	IN	A	your_address
	2. fastly.net.		*****	IN	NS	ns1.***.dynect.net.
	3. fastly.net.		*****	IN	NS	ns2.***.dynect.net.
	4. fastly.net.		*****	IN	NS	ns3.***.dynect.net.
	4. fastly.net.		*****	IN	NS	ns4.***.dynect.net.

After that copy that <code>your_address</code> to the A record in that domain provider.

It's better if you create 2 records and name them as (your_url.com) and (www.your_url.com) and copy that address in both the records. 

Then wait for about 15 minutes and then all done. 

Your blog is now updated at your_url.com. \o/

Next I will show how to make custom pages using Octopress.

Sorry for the comment bar because I don't have that active now. Will fix that later on. :)