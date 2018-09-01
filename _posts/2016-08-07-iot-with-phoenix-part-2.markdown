---
layout: post
title: "iot with phoenix part 2"
date: 2016-08-07 21:23:42 +0530
comments: true
categories: 
---
In part 1, I have demonstrated how to create MVC based user authentication and a plug for the same with Phoenix. Now, in this tutorial we will see how to display some data using websockets. Websocket connections are consistent. So, for displaying the real time data from the machine, we need to use the channel feature of phoenix, where we can update the data on the page in real time. 

1. The channel should be user specific. Users can view their own sensor outputs of the machines that they have privately. 

2. There should be a reverse communication from users to machines. With this, users can be able to switch on or off the machine along with some other things like controlling speed, displaying something on a LCD screen and so on. 

So, let's create a channel for the users. We will make use of something that will let us make the users' communication private with their machines. 

	$mix phoenix.gen.channel User

It will create a file called `user_channel.ex` in `web/channles/` directory. It contains the following, 

```ruby
	defmodule Iot.UserChannel do
	  use Iot.Web, :channel

	  def join("user:lobby", payload, socket) do
	    if authorized?(payload) do
	      {:ok, socket}
	    else
	      {:error, %{reason: "unauthorized"}}
	    end
	  end

	  # Channels can be used in a request/response fashion
	  # by sending replies to requests from the client
	  def handle_in("ping", payload, socket) do
	    {:reply, {:ok, payload}, socket}
	  end

	  # It is also common to receive messages from the client and
	  # broadcast to everyone in the current topic (user:lobby).
	  def handle_in("shout", payload, socket) do
	    broadcast socket, "shout", payload
	    {:noreply, socket}
	  end

	  # Add authorization logic here as required.
	  defp authorized?(_payload) do
	    true
	  end
	end

```

The join method has a argument `user:lobby` by default. It is called the `topic:subtopic` pair. The topic here is `user` and the subtopic is `lobbby`. The `handle_in` method has the first argument as `ping` or `shout`. Those are called events. Once a user is joined to the subtopic, the 	`handle_in` methods can show what messages are coming to that subtopic through an event and that `handle_in` method can also broadcast a message upon arrival through an event. Other subscribers (who have joined to that same subtopic) can get the message through that event.

Making an analogy with our required task, we need to make the subtopic unique for each user. Then we need to create 2 events. One for displaying stuff on a webpage through an event broadcast (broadcasting to a particular event), the other is to broadcast the reverse message from the user to control stuff at the machine. Let's name those 2 events as `sensor_output` and `control`. So, our version of `user_channel.ex` is given below.

```ruby
	defmodule Iot.UserChannel do
	  use Iot.Web, :channel

	  def join("users:" <> user_token, payload, socket) do
	    if authorized?(payload) do
	      {:ok, "Joined To User:#{user_token}", socket}
	    else
	      {:error, %{reason: "unauthorized"}}
	    end
	  end

	  # Channels can be used in a request/response fashion
	  # by sending replies to requests from the client
	  

	  def handle_in("control", payload, socket) do
	    broadcast socket, "control", payload
	    {:noreply, socket}
	  end

	  def handle_in("sensor_output", payload, socket) do
	    broadcast socket, "sensor_output", payload
	    {:noreply, socket}
	  end

	  # Add authorization logic here as required.
	  defp authorized?(_payload) do
	    true
	  end
	end

```

Now, from the above `user_channel`, it's clear what the two `handle_in` methods do on arrival of a new message. They just broadcast it to the respective events. But the join event has the subtopic to be added to the topic `users`. The subtopic we are using is the `user_token` that is saved as a string in the `Users` table whenever a user registers in the application. It has been written in the `Password` library, refer to the previous blog post. Now, we have to tell our `socket` file to enable the `users` topic with a wild card subtopic. Add the following line.

```ruby
	#web/channes/user_socket.ex
	channel "users:*", Iot.UserChannel
``` 

All set with the background process handlers. Now, let's move to the front-end. We need a webpage to show all the messages that comes through `sensor_output` event. Before that, the webpage has to be joined with the `users:user_token` topic:subtopic. The front-end we will automate with some JS code. Before that, the JS code should have the knowledge of the `user_token`, otherwise it can't be able to join the topic. A plain JS code can't invoke the `user_token` from the database directly. So, we need to take that `user_token` from that very template where we want to show the content. The question is, where shall the template render the `user_token` from ? The answer is pretty simple. From the controller it has been associated with. Voila ! now we have figured out what to do. So, let's make a model called `energy_meter`. The model wil be used later. For now, we will use a template only. We are not doing anything with the model now. It's just for a future use. 

	$mix phoenix.gen.model EnergyMeter energy_meters name:string pf:integer reading:integer thd:integer load:integer

Then let's change the template under the folder `energy_meter` inside the templates folder. The controller is given below.

```ruby
	#web/controller/energy_meter_controller.ex
	defmodule Iot.EnergyMeterController do
	  use Iot.Web, :controller
	  
	  plug Iot.Plug.Authenticate

	  def index(conn, _params) do
	    current_user = get_session(conn, :current_user)
	    render conn, "index.html", current_user: current_user
	  end
	end 

```

The template is given below

```html
	#web/templates/energy_meter/index.html.eex
	<ul id="em" data-id=<%= @current_user.token %>>

	</ul>
	<div class = "container">
	  <div class = "row">
	  
	    <div class = "span4">
	      <h4>Load</h4>
	      <div id = "load">
	      </div>
	    </div>
	  

	   
	    <div class = "span4">
	      <h4>Power Factor</h4>
	      <div id = "pf">
	      </div>
	    </div>
	  

	   
	    <div class = "span4">
	      <h4>THD</h4>
	      <div id = "thd">
	      </div>
	    </div>
	  

	   
	    <div class = "span4">
	      <h4>Reading</h4>
	      <div id = "reading">
	      </div>
	    </div>
	  
	  
	</div>




	  <div class = "btn btn-primary" id="on">ON</div>
	  <div class = "btn btn-primary" id="off">OFF</div>
	  <%= link("Logout", to: session_path(@conn, :delete), class: "btn btn-success pull-right") %>
	</div>

```
In this way the `user_token` has been retrieved on to the template. Form the `data-id` of that division, we can take away that value to our JS files.

Now, the html part is done. Let's write the JS parts to automate the process. Using jQuery is a better option here as far as ease of writing code is concerned. In the parent directory of the project a bower install will install jQuery libs for us.

	$bower install

Now, let's create a `user.js` file in `web/static/js` folder. Before writing something, let's comment  the default code for joining a `topic:subtopic`in `socket.js`

```javascript
	//let channel = socket.channel("topic:subtopic", {})
	//channel.join()
	  //.receive("ok", resp => { console.log("Joined successfully", resp) })
	  //.receive("error", resp => { console.log("Unable to join", resp) })
```

Now, the content to write in the `user.js` file is below. 

```javascript

	import socket from "./socket"

	$(function() {
	  let ul = $("ul#em")
	//let message = $("div#message") 
	  if (ul.length) {
	    var token = ul.data("id")
	    var topic = "users:" + token
			
	    // Join the topic
	    let channel = socket.channel(topic, {})
	    channel.join()
	      .receive("ok", data => {
	        console.log("Joined topic", topic)
	      })
	      .receive("error", resp => {
	        console.log("Unable to join topic", topic)
	      })
				

				$("#on").click(function(){
						channel.push("control", {val: "on"});
				})
				$("#off").click(function(){
						channel.push("control", {val: "off"})
				})

				channel.on("control", data => {
						console.log("Recieved: ", data.val);
				})
				channel.on("sensor_output", data => {
					$("#load").html(data['load']);
					$("#pf").html(data['pf']);
					$("#thd").html(data['thd']);
					$("#reading").html(data['reading']);
				})
				
	  }
	});
```

This code fetches the value of token from `u.data("id")` from that html template. The topic variable is the concatenation of `users` and the `token`. Then the JS client joins the topic. On join, the `topic:subtopic` is printed on to the console of that web page. Then, there are some event based automation is written. When the button with id `on` is pressed there at the webpage, the data `val: "on"` is sent via the `control` event. And similarly for the `off` button, the data is sent via `control` event. Again here, the message is handled and printed on to the console with the following. 

```javascript
	channel.on("control", data => {
		console.log("Recieved: ", data.val);
	})
```

So, we can view on the console what the value has been sent from the `on` and `off` buttons. Then the next method in the file displays the `sensor_output` data on to the page. Now, let's add this file to the app JS file so that it can be added to all the templates.

```javascript
   // web/static/js/app.js
   import user from "./user"

```
Now, the button press evens can be tested. Remember, that console messages  `on` and `off` can only be seen for a user if he/she is logged in. 

For the `sensor_output` event, let's broadcast something over that event from the interpreter.

	$iex -S mix phoenix.server

Then using the `Endpoint.broadcast` method we can broadcast a message over a event within a topic. 

	iex(2)> Iot.Endpoint.broadcast("users:anVhbkBnbWFpbC5jb21qdWxpYTEyMw==", "sensor_output", %{"power_factor" => 23, "load" => 1000, "thd" => 4, "reading" => 1800})
	:ok
	iex(3)> Iot.Endpoint.broadcast("users:anVhbkBnbWFpbC5jb21qdWxpYTEyMw==", "sensor_output", %{"power_factor" => 04, "load" => 900, "thd" => 2, "reading" => 1900})
	:ok

As soon as you run, you can see the values updating automatically on the webpage. Similarly, for the `control` event, just clicking the `on` and `off` buttons will do what we want. It will print the message on to the console. A demo screen recording of that is given below. My project name was tworit so I used `Tworit.Endpoint`. Likewise, here, `Iot.Endpoint` can be used.

<iframe src="https://player.vimeo.com/video/177943594" width="640" height="400" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
<p><a href="https://vimeo.com/177943594">phoenix_channels</a> from <a href="https://vimeo.com/user29276136">Tworit</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

In the next part, we will do some python 3.5 asyncio. With the help of that, we can send data from a raspberry pi to the `sensor_output` event. In addition to that, we can receive the `on` and `off` signals from the server to turn on and off our machine. 
	
 



