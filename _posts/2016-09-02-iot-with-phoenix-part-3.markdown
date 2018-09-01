---
layout: post
title: "IoT with phoenix part 3"
date: 2016-09-02 13:28:35 +0530
comments: true
categories: 
---
This is the last part in the series.

In the previous blog post, the browser client was getting messages from the elixir interpreter inside the project directory using the `Endpoint.broadcast` method. Now, for monitoring sensor outputs, we have to send and receive data from sensors, we need to remotely configure a client. I am using a raspberry pi with python GPIO module to interface the sensors. So, we are going to accomplish the following tasks in this part 3.

1. Join the phoenix channel and send a random value form a python client using websockets.
2. Sending data from the serialport. (Sensors)

The Phoenix channel API is damn easy to understand. It has `phx_join` event is for joining a channel, `phx_reply` for a reply after join. Following the previous blog, we have a event called sensor_output with a topic `users:user_token` (user_token is the token generated for a user). So, the following python code is capable of joining the channel topic and sending a sample random value.

```python
    import asyncio
    import websockets
    import json
    import time
    from random import randint

    async def hello():
        async with websockets.connect('ws://127.0.0.1:4000/socket/websocket') as websocket:
            data = dict(topic="users:your_user_token", event="phx_join", payload={}, ref=1)

            #data is a dictionary containing necessary info for a join request to the topic.

            await websocket.send(json.dumps(data))
            print("joined")
              
            print("Joined") #joined the topic user:user_token
            while True:
                msg = await retrieve() #waiting for retrieve function to return a value

                await websocket.send(json.dumps(msg))
                #sending the message to the phoenix channel
                  
                call = await websocket.recv() #constantly receiving data from the channel
                control = json.loads(call) #converting to json
                print(control)
                  
                time.sleep(0.5) #0.5 second delay

        async def retrieve():
          
          msg = dict(topic="users:your_user_token", event="sensor_output", payload={"load":"1000", "pf":str(randint(0,100)), "thd":"120", "reading":"1800"}, ref=None)

          #message dictionary containing necessary info for sending the data to the channel
          time.sleep(0.5)
          return msg


    asyncio.get_event_loop().run_until_complete(hello())
    asyncio.get_event_loop().run_forever()
````
This is a piece of asynchronous code written in python, in which it joins the phoenix channel and waits until data comes form another function and sends it to the phoenix server.

Now if we run this script, we can see the data updated in the webpage from time to time with random values.

Now, there was a outward message from the channel too through the `control` event. We can keep track of that too (The button click events of blog post 2) just by comparing the `event` key of the json string `control`. If the event name is `control`, we can make use of that too.


```python
    import asyncio
    import websockets
    import json
    import time
    from random import randint

    async def hello():
        async with websockets.connect('ws://127.0.0.1:4000/socket/websocket') as websocket:
            data = dict(topic="users:your_user_token", event="phx_join", payload={}, ref=1)

            #data is a dictionary containing necessary info for a join request to the topic.

            await websocket.send(json.dumps(data))
            print("joined")
            
            print("Joined") #joined the topic user:user_token
            while True:
                msg = await retrieve() #waiting for retrieve function to return a value

                await websocket.send(json.dumps(msg))
                print("sent {}".format(msg))
                #sending the message to the phoenix channel
                
                call = await websocket.recv() #constantly receiving data from the channel
                control = json.loads(call) #converting to json

                if(control['event'] == 'control'):
                    print(control['payload']['value'])
                
                time.sleep(0.5) #0.5 second delay

    async def retrieve():
        
        msg = dict(topic="users:your_user_token", event="sensor_output", payload={"load":"1000", "pf":str(randint(0,100)), "thd":"120", "reading":"1800"}, ref=None)

        #message dictionary containing necessary info for sending the data to the channel
        time.sleep(0.5)
        return msg


    asyncio.get_event_loop().run_until_complete(hello())
    asyncio.get_event_loop().run_forever()
```
This script prints the `payload` value if the event name is `control`. That is when there is a button click event, it will print `on` or `off` depending on the buttons.

Now, let’s write some code where we can get data from the serialport. All you need is the `pyserial` library and receiving some data from there like the following.

```python
	import serial

	ser = #ser =serial.Serial("/dev/ttyAMA0", 9600, timeout=1)

	#rest of the code

	async def retrieve()

		data = ser.readline().decode()
		msg = dict(topic="users:your_user_token", event="sensor_output", payload={"load":"1000", "pf":str(randint(0,100)), "thd":data, "reading":"1800"}, ref=None)

		return msg
		#rest of the code
```
Here the data will be received from the serialport and will be updated at `thd` on the webpage.

There are several other examples I have written, by using those in raspberry pi, we can send and receive data from the websocket phoenix server. Examples include some `arduino firmata` codes too.

Python clients are here.

P.S. I have moved to another city for my first ever job. This is my first blog post from Bangalore city. Happy Hacking ! :D :)
