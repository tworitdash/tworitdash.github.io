---
layout: post
title: "IoT with Phoenix Part 1"
date: 2016-07-24 20:24:01 +0530
comments: true
categories: 
---

This is the first blog post that I am writing to share my experience with the Phoenix framework in building an Iot application. I have written a blog post about Elixir and Phoenix [here](https://blog.zairza.in/generators-make-the-whole-thing-look-sexy-2434154a8e0e#.riq5apurj). The objectives that we are going to achieve in here are

1. A 'Model View Controller' scheme for the users. So that the users can register themselves in the application and have a login access to monitor as well as control their machines. 

2. A messaging interface between the machine and the user so that the application can be pretty much asynchronous and fast. This will accomplish the goal of an user specific Iot architecture, where a user can control and monitor only his/her machines, not others. There is no need of refreshing the pages to know the current state of the machines as we will be using websocket connections to make it a real time application, where the connection to the server never goes away. 

3. Writing machine clients. The clients which will help the machine send sensor outputs to the server.

Phoenix is a framework written in Elixir programming language which runs on Erlang VM. The installation instructions for the framework is given [here](http://www.phoenixframework.org/docs/installation). After successful installation, let's start building the application. 

To create our Iot project run the following in the terminal.

	$mix phoenix.new iot

Now, enter into the application. 
Note: you must have postgres installed in your system for the database requirements. 

	$cd iot

Now run the server or you can run the server within an interpreter too.

	$mix phoenix.server 

	or

	$iex -S mix phoenix.server 

Now we can view the application at http://localhost:4000/. Now let's change the contents of some files to have the default page as the login page for users. To achieve that, we should have an users table in the database with the details of the users as attributes. For that, we have to generate a users model using the mix model generator. 

	$mix phoenix.gen.model User user username:string encrypted_password:string email:string token:string 

It will create a file called ```user.ex``` in the ```web/models/``` directory. Now the users table has 4 attributes called the `username`, `encrypted_password`, `email` and a `token`. But, to register a user with a password for login purposes, we should have two virtual fields, the `password` field and a `password_confirmation` field. These are virtual attributes and they are never stored as attributes of the users table. The password after entered in the registration form is converted into a encrypted form and saved in the database as encrypted password. When the user logs in later, again that entered password is encrypted and matched with the encrypted password already saved in the database for that user. This process helps in a secured access by not storing the password anywhere during the login or register process. The user only knows his password, no one else knows, not even the admins of the application. :D 

Now, let's add those virtual fields and have some validations for the attributes in ```user.ex``` file. 

```ruby
	defmodule Iot.User do
	  use Iot.Web, :model
	  alias Iot.Repo

	  schema "users" do
	    field :username, :string
	    field :email, :string
	    field :encrypted_password, :string
	    field :password, :string, virtual: true
	    field :password_confirmation, :string, virtual: true
	    field :token, :string
	    timestamps
	  end
	  

	  @required_fields ~w(username email password password_confirmation)
	  @optional_fields ~w()

	  @doc """
	  Creates a changeset based on the `model` and `params`.

	  If no params are provided, an invalid changeset is returned
	  with no validation performed.
	  """
	  def changeset(model, params \\ :empty) do
	    model
	    |> cast(params, @required_fields, @optional_fields)
	    |> unique_constraint(:username, on: Repo, downcase: true)
	    |> validate_length(:password, min: 8)
	    |> validate_length(:password_confirmation, min: 8)
	    |> validate_confirmation(:password)
	  end
	end
```


Here, the required fields doesn't include the `encrypted_password `field and the reason is obvious. The `encrypted_password` we are going to generate later. Now, to register the users, we should have a registration controller, a registration template of course with a form to be filled by the users, and a url like http://localhost:4000/registraion. So, let's modify the ```web/router.ex``` file. 

```ruby
	defmodule Iot.Router do
	  use Iot.Web, :router
	  

	  pipeline :browser do
	    plug :accepts, ["html"]
	    plug :fetch_session
	    plug :fetch_flash
	    plug :protect_from_forgery
	    plug :put_secure_browser_headers
	  end

	  pipeline :api do
	    plug :accepts, ["json"]
	  end

	  scope "/", Iot do
	    pipe_through :browser # Use the default browser stack
	    get "/registration", RegistrationController, :new
	    post "/registration", RegistrationController, :create
	    get "/", PageController, :index
	    
	  end

	end
```

Now we have added 2 routes, one to get the content (The user registration form) and the other is a post request for the same. Now we need to have a ```registration_controller.ex``` file in the `web/controller` directory, where we are going to write the ```new``` and `create` methods. 

```ruby
	defmodule Iot.RegistrationController do
	  use Iot.Web, :controller

	  alias Iot.Password

	  def new(conn, _params) do
	    changeset = User.changeset(%User{})
	    render conn, changeset: changeset
	  end

	  def create(conn, %{"user" => user_params}) do
	    changeset = User.changeset(%User{}, user_params)
	    if changeset.valid? do
	      new_user = Password.generate_password_and_store_user(changeset)
	      conn
	        |> put_flash(:info, "You are Sucessfully Registered :P ")
	        |> redirect(to: page_path(conn, :index))
	    else
	      render conn, "new.html", changeset: changeset 
	    end
	  end
	end
```
Here in the new method, we are accepting the attributes of the user in the variable `changeset`. The create method checks if those required fields fulfill the validations present in `web/models/user.ex` by `changeset.valid?` method and stores the user in the database and renders the page_index page. (The default page at http://localhost:4000/ ). If the `changeset.valid?` is not fulfilled again the new registration page will open up. 

The saving of the user in the database by creating the `encrypted_password` is done here by the ```Password``` library. Let's write the password library with the `generate_password_and_store_user` that we have just used in the registration controller and other methods. 

```ruby
#lib/Iot/password.ex
	defmodule Iot.Password do
	  	alias Iot.Repo
	  import Ecto.Changeset, only: [put_change: 3]
	  import Comeonin.Bcrypt, only: [hashpwsalt: 1]


	  def generate_password_and_token(changeset) do
	    to_be_encoded_string = Enum.join([changeset.params["email"], changeset.params["password"]])

	    token = Base.encode64(to_be_encoded_string)
	    changeset = put_change(changeset, :token, token)

	    put_change(changeset, :encrypted_password, hashpwsalt(changeset.params["password"]))
	  end


	  def generate_password_and_store_user(changeset) do
	    changeset
	      |> generate_password_and_token
	      |> Repo.insert
	  end
	end
```

Here I have used `comeonin` package to encrypt the password. You can get it by adding it to the dependencies in the mix.exs file as 

```ruby
	defp deps do
	    [{:phoenix, "~> 1.1.4"},
	     {:postgrex, ">= 0.0.0"},
	     {:phoenix_ecto, "~> 2.0"},
	     {:phoenix_html, "~> 2.4"},
	     {:phoenix_live_reload, "~> 1.0", only: :dev},
	     {:gettext, "~> 0.9"},
	     {:cowboy, "~> 1.0"},
	    {:comeonin, "~> 2.5"}]
	  end
```
Then install it through 

	$mix deps.get 

The `generate_password_and_token` method generates the encrypted password and a token(to be used later) for the user. The `generate_password_and_store_user` method stores the user in the database. Now, it's time to add a template for the new registration page. Create a directory named registration in the templates folder and add a new.html.eex file in it. Fill it with the content below.

```html
	<h3>Registration</h3>
	<%= form_for @changeset, registration_path(@conn, :create), fn f -> %>
	  <%= if f.errors != [] do %>
	    <div class="alert alert-danger">
	      <p>Oops, something went wrong! Please check the errors below:</p>
	      <ul>
	        <%= for {attr, message} <- f.errors do %>
	          <li><%= humanize(attr) %> <%= translate_error(message) %></li>
	        <% end %>
	      </ul>
	    </div>
	  <% end %>

	  <div class="form-group">
	    <label>Username</label>
	    <%= text_input f, :username, class: "form-control" %>
	  </div>

	  <div class="form-group">
	    <label>Email</label>
	    <%= text_input f, :email, class: "form-control" %>
	  </div>


	  <div class="form-group">
	    <label>Password</label>
	    <%= password_input f, :password, class: "form-control" %>
	  </div>

	  <div class="form-group">
	    <label>Password Confirmation</label>
	    <%= password_input f, :password_confirmation, class: "form-control" %>
	  </div>

	  <div class="form-group">
	    <%= submit "Register", class: "btn btn-primary" %>
	    <%= #link("Login", to: session_path(@conn, :new), class: "btn btn-success pull-right") %>
	  </div>
	<% end %>
```
The session_login  button is now commented because we haven't added the sessions controller yet. 

Let's try it all out. First we have to create the database for the application using ecto.

	$mix ecto.create

Then, we have to migrate the changes that we have in the users model. 

	$mix ecto.migrate

Now we have to restart the server as we have added a new lib file called `password.ex`. Then, check if that registration form at http://localhost:4000/registration/ is working. If it renders the default phoenix page with a "You are Sucessfully Registered :P", it's working. 

Now let's replace the default phoenix page with a login page for the users. Let's understand what a session is. Sessions are the users' active time spans after login. A sessions controller matches the username and password of the user and renders the pages. A session controller stores the users data (you can customize the data to be stored) for the session. It is recommended to store minimum required data like only the username or the email in the session. With a logout request, we free the session variables. So, now we have to add a ```login``` and a ```logout``` route in the ```router.ex``` along with a ```new``` route for the session. The page route will be replaced by the ```new``` method of the session. 

```ruby
	scope "/", Iot do
	    pipe_through :browser # Use the default browser stack
	    get "/registration", RegistrationController, :new
	    post "/registration", RegistrationController, :create
	    get "/", SessionController, :new
	    post "/login", SessionController, :create
	    get "/logout", SessionController, :delete
	end
```

Clearly from the routes, we now know that we have to write a `session_controller.ex` in the `web/controllers` directory with new, create and delete methods in it.

```ruby
	#web/controllers/session_controller.ex
	defmodule Iot.SessionController do
	  use Iot.Web, :controller

	  plug :scrub_params, "user" when action in [:create]
	  plug :action

	  def new(conn, _params) do
	    render conn, changeset: User.changeset(%User{})
	  end

	  def create(conn, %{"user" => user_params}) do
	    user = if is_nil(user_params["username"]) do
	      nil
	    else
	      Repo.get_by(User, username: user_params["username"])
	    end

	    user
	      |> sign_in(user_params["password"], conn)
	  end

	  def delete(conn, _) do
	    delete_session(conn, :current_user)
	      |> put_flash(:info, 'You have been logged out')
	      |> redirect(to: session_path(conn, :new))
	  end

	  defp sign_in(user, password, conn) when is_nil(user) do
	    conn
	      |> put_flash(:error, 'Could not find a user with that username.')
	      |> render "new.html", changeset: User.changeset(%User{})
	  end

	  defp sign_in(user, password, conn) when is_map(user) do
	    cond do
	      Comeonin.Bcrypt.checkpw(password, user.encrypted_password) ->
	        conn
	          |> put_session(:current_user, user)
	          |> put_flash(:info, 'You are now signed in.')
	          |> redirect(to: energy_meter_path(conn, :index))
	      true ->
	        conn
	          |> put_flash(:error, 'Username or password are incorrect.')
	          |> render "new.html", changeset: User.changeset(%User{})
	    end
	  end
	end
```
The code above is self explanatory. The `sign_in` method lets the user log into the pages. The `put_session` method stores temporary session data. In this case the user is saved in the session as `:current_user`. Now, we will write the new template for the login form. Create a folder called session in the `web/templates/` folder and a file called new.html.eex in it. 

```html
	<h3>Login</h3>
	<%= form_for @changeset, session_path(@conn, :create), fn f -> %>
	  <%= if f.errors != [] do %>
	    <div class="alert alert-danger">
	      <p>Oops, something went wrong! Please check the errors below:</p>
	      <ul>
	        <%= for {attr, message} <- f.errors do %>
	          <li><%= humanize(attr) %> <%= translate_error(message) %></li>
	        <% end %>
	      </ul>
	    </div>
	  <% end %>

	  <div class="form-group">
	    <label>Username</label>
	    <%= text_input f, :username, class: "form-control" %>
	  </div>

	  <div class="form-group">
	    <label>Password</label>
	    <%= password_input f, :password, class: "form-control" %>
	  </div>

	  <div class="form-group">
	    <%= submit "Login", class: "btn btn-primary" %>
	    <%= link("Sign Up", to: registration_path(@conn, :new), class: "btn btn-success pull-right") %>
	  </div>
	<% end %>
```

Now, we can uncomment the line in `web/templates/registration/new.html.eex` for the session login path. And we change the `create` method of the registration controller to render the login page rather than the default phoenix page.

```ruby
	def create(conn, %{"user" => user_params}) do
	    changeset = User.changeset(%User{}, user_params)
	    if changeset.valid? do
	      new_user = Password.generate_password_and_store_user(changeset)
	      conn
	        |> put_flash(:info, "You are Sucessfully Registered :P ")
	        |> redirect(to: session_path(conn, :new))
	    else
	      render conn, "new.html", changeset: changeset 
	    end
	end
```

 Now, where will it go after login? We must have some place where it should move to after login and we must have a control over that page so that that page can not be opened unless the user is logged in. That is why the line ```redirect(to: energy_meter_path(conn, :index))``` is added in the `sign_in` method (EnergyMeter is our Iot device). We will create a energy_meter template with only the username of the user in it. At first, let's edit the router.ex file.

```ruby
	scope "/", Iot do
	    pipe_through :browser # Use the default browser stack
	    get "/registration", RegistrationController, :new
	    post "/registration", RegistrationController, :create
	    get "/", SessionController, :new
	    post "/login", SessionController, :create
	    get "/logout", SessionController, :delete
	    get "/em", EnergyMeterController, :index
	end
```
Now let's create a ```energy_meter_controller.ex```. 

```ruby
	defmodule Iot.EnergyMeterController do
	  use Iot.Web, :controller
	  
	  plug Iot.Plug.Authenticate

	  def index(conn, _params) do
	    current_user = get_session(conn, :current_user)
	    render conn, "index.html", current_user: current_user
	  end
	end
```

Now let's write the template for this. 

```html
	#web/templates/energy_meter/index.html.eex
	<div>Hi <%= @current_user.username %></div>
	<%= link("Logout", to: session_path(@conn, :delete), class: "btn btn-success pull-right") %>
```

This has the username of that user and a logout button. The controller has a Authenticate Plug, which ensures the authenticity of the current user. If the user is not logged in, this Plug helps not to show any page in the EnergyMeter controller. Let's write that Plug. We have to create a directory called `authentication` in the `web` directory and add `authenticate.ex` file in it. 

```ruby
	defmodule Iot.Plug.Authenticate do
	  import Plug.Conn
	  import Iot.Router.Helpers 
	  import Phoenix.Controller

	  def init(default), do: default

	  def call(conn, default) do
	    current_user = get_session(conn, :current_user)
	    if current_user do
	      assign(conn, :current_user, current_user)
	    else
	      conn
	        |> put_flash(:error, 'You Need to be signed in to view this page !')
	        |> redirect(to: session_path(conn, :new))
	    end
	  end
	end
```

The code is self explanatory. If a user is trying to get the energy_meter index page without logging in, it will throw the error as "You Need to be signed in to view this page !". Now try that all out by going to http://localhost:4000/. 

Note: a view must be added with all the controllers. Otherwise, it will throw an error. A demo view in the views folder is given below.

```ruby
	#web/views/session_view.ex
	defmodule Iot.SessionView do
  		use Iot.Web, :view
	end
```

Now, the authentication part is done. In the next part, we will code the messaging application that is needed for users to listen and control their machines. 

Happy Hacking ! 

Reference - http://meatherly.github.io/2015/05/11/phoenixauthentication/ 




