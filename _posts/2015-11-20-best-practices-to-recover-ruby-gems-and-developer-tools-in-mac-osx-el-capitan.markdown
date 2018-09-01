---
layout: post
title: "Best Practices to Recover Ruby Gems and Developer Tools in Mac OSX El Capitan"
date: 2015-11-20 11:36:22 +0530
comments: true
categories: 
---
El Capitan has Darwin-15 (different from the last kernel). The first step that I found is to disable SIP (System Integrity Protection) by the following the steps below.

	1. Rebooting in recovery mode by long pressing command + R on reboot
	2. Accessing the terminal by going to utilities 
	3. run the following in the terminal 
	
	csrutil disable

Homebrew requires access to the path /usr/local. So we need to have access to this path by using the following commands.

	
	sudo chflags norestricted /usr/local && sudo chown $(whoami):admin /usr/local && sudo chown -R $(whoami):admin /usr/local
		
After all these, it's the best practice to update xcode to version 7.1 and install the command line tools as well. There are a lot of ways to do this.

Run the following in the terminal 
	
	xcode-select --install

If the above way fails, just click on xcode application and go to xcode -> Open Developer Tool -> More Developer Tools. It will take to you to the apple developer site. Just login there and according to the OS and Xcode version you have, download the command line tools file with the .dmg extension and install it.

Or else, the best way is to click on the mac app store and check for updates. There must be an update to install the command line tools and after that it's done.

### Fixing Gem native extension 

I have a blog configured with Octopress and after updating the system to 10.11, bundle install always failed. With the command line tools installed and with proper permissions set to /usr/local/, I got the error while running 

	bundle exec rake preview

Error was 

	Starting to watch source with Jekyll and Compass. Starting Rack on port 4000
	rake aborted!
	Errno::ENOENT: No such file or directory - compass
	/Users/user/git/octopress/Rakefile:85:in spawn
	/Users/user/git/octopress/Rakefile:85:in block in <top (required)>
	Tasks: TOP => preview

To have this removed, I prefered installing ruby from rbenv. Before that I have been using the system ruby. With rbenv, we can have the flexibity of having different versions of ruby installed for different projects. With the above fixes, homebrew must be working as usual. 

	brew update
	brew install rbenv ruby-build

Ruby-build is an additional dependency for rbenv. After that we need to set the path so that we can have the command line utility of rbenv. 

	echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
	source ~/.bash_profile

The above instruction adds a PATH variable to the .bash_profile to have the utility. 

Then we need to install ruby from rbenv and to have a version of our choice globally. I preferred 2.2.3.

	rbenv install 2.2.3
	rbenv global 2.2.3

Now if we check 

	ruby -v 
	ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin15]

Now I wanted to have this version installed locally in my octopress blog. I just entered into it and ran the following.

	rbenv rehash
	rbenv local 2.2.3

Then I installed all the necessary gems by 
	
	bundle install 

But I eneded up with some errors that uses some versions specific issues. My Gemfile looked like this before. 

	cat Gemfile
	source "https://rubygems.org"

	group :development do
	  gem 'rake', '~> 10.0'
	  gem 'jekyll', '~> 2.0'
	  gem 'octopress-hooks', '~> 2.2'
	  gem 'octopress-date-format', '~> 2.0'
	  gem 'jekyll-sitemap'
	  gem 'rdiscount', '~> 2.0'
	  gem 'RedCloth', '~> 4.2.9'
	  gem 'haml', '~> 4.0'
	  gem 'compass', '~> 1.0.1'
	  gem 'sass-globbing', '~> 1.0.0'
	  gem 'rb-fsevent', '~> 0.9'
	  gem 'stringex', '~> 1.4.0'
	  gem 'therubyracer'
	end

	gem 'sinatra', '~> 1.4.2'

Then I just removed the versions from the right side of each gem.

	cat Gemfile 
	source "https://rubygems.org"

	group :development do
	  gem 'rake'
	  gem 'jekyll'
	  gem 'rdiscount'
	  gem 'therubyracer'
	  gem 'pygments.rb'
	  gem 'RedCloth'
	  gem 'haml'
	  gem 'compass'
	  gem 'sass'
	  gem 'sass-globbing'
	  gem 'rubypants'
	  gem 'rb-fsevent'
	  gem 'stringex'
	  gem 'liquid'
	  gem 'directory_watcher'
	  gem 'json'
	end

Then I removed Gemfile.lock file to install gems locally from scratch again.

	rm Gemfile.lock
	gem pristine --all 
	bundle install

Now :

	bundle exec rake preview
	Starting to watch source with Jekyll and Compass. Starting Rack on port 4000
	/Users/tworit/.rbenv/versions/2.2.3/lib/ruby/gems/2.2.0/gems/liquid-2.3.0/lib/liquid/htmltags.rb:44: warning: duplicated key at line 47 ignored: "index0"
	[2015-11-20 13:45:50] INFO  WEBrick 1.3.1
	[2015-11-20 13:45:50] INFO  ruby 2.2.3 (2015-08-18) [x86_64-darwin15]
	[2015-11-20 13:45:50] INFO  WEBrick::HTTPServer#start: pid=82642 port=4000
	Configuration from /Users/tworit/tworitdash.github.io/_config.yml
	Auto-regenerating enabled: source -> public
	[2015-11-20 13:45:50] regeneration: 150 files changed
	>>> Change detected at 13:45:51 to: screen.scss
	identical public/stylesheets/screen.css 
	>>> Compass is watching for changes. Press Ctrl-C to Stop.


Now, everything should work fine. :) Happy Hacking !



