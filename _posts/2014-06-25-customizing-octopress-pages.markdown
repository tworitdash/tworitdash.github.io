---
layout: post
title: "Customizing Octopress Pages"
date: 2014-06-25 22:42:43 +0530
comments: true
categories: 
---
After creating a simple blogging site, let's now create some custom pages for our site like about and home pages.

Before that if you want to publish the blog page in your_url.com/blog instead of your_url.com and you just want your own index page at your_url.com, then just open up the Rakefile and edit the <code>blog_index_dir</code> to :
	
	1. blog_index_dir  = 'source/blog'

so that the blog page is now created at the your_url.com/blog.

To have your own page for the home, rake has another task for you called the <code>rake new_page</code>. If you are writing it as <code>bundle exec rake new_page["index.html"]</code>, then it will create a index html page in that source directory.

so follow the command:

	1. bundle exec rake new_page["index.html"]

Then go and edit it as you like.

For an instance let us change the layout. make it something like :

	1. layout: home

Now we are telling the index.html file to follow the home layout. But we don't have any till now. So go to your <code> layouts </code> folder and create a home.html file and add whatever you like and if you want to include your own head, header and footer files in home.html then just create those files in <code>includes</code> folder and add the lines in home.html as:

```html
{% raw %}

	<html>
	 
	 	{% include custom_head.html %}
	 
		<body>

      		<div class="any_class_in_your_css" >
      		
        			{% include custom_header.html %}
        	
        			<div class="any_other-class" >
           		 
            
            
             			{{ content }}

            
            
           			{% include custom_footer.html %}
           
     		 		</div>

      		</div>

     	</body>

    </html>
{% endraw %}
```

And add your stylesheets in the <code>stylesheets</code> folder. And write the content, as we do in the `_posts` files for the blogs, in the index.html file. 

And your custom page is done. Make sure in the header the navigation bar is correctly coded like :


```html
{% raw %}
			<li><a href="{{ root_url }}/">Home</a></li>
			<li><a href="{{ root_url }}/about">About</a></li>
			<li><a href="{{ root_url }}/blog">Blog</a></li>
			<li><a href="{{ root_url }}/blog/archives/">Archives</a></li>
			<li><a href="{{ root_url }}/atom.xml">RSS</a></li>

{% endraw %}
```

Same links should be provided in the `_includes/custom/navigation.html`(as the blog page has this navigation file embedded. ). Then all done to preview. 

But notice that in the navigation file I added the second line to link to a about folder and that will show in the browser like <code>your_url.com/about</code>.

How to do this? It's much simpler than the first one.

	1. bundle exec rake new_page[about]

A page without any extension is created as index.html within the desired folder (here it's about). 

Then just open that index file and do whatever you want to customize it.

And most importantly don't write the link for the home page as just <code>{% raw %}{{ root_url }} {% endraw %}</code> in the navigation file and do write it as <code>{% raw %}{{ root_url }}{% endraw %}/</code>, otherwise the link will point to the same page which is being opened up in the browser. 

All is set now and just run the commands:

	1. bundle exec rake generate
	2. bundle exec rake preview
	3. bundle exec rake deploy

And all your codes are on the web now. 

Open up your_url.com or your_url.github.io and have fun. :) :)
