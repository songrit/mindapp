# Mindapp
*  Branch master

I like to develop application using Ruby on Rails. I find that most of my projects has some common tasks such as basic design, user administration, logging, workflow, etc. So I decide to use mind map to act as a language to explain what I want and have the tool generates the application that conform to standard framework so I can then customize everything later on. Mind map is used in design phase where it generates models and controller, in execution phase where it controls the work flow, and also use to generate documentation. System Analyst could use mind map to communicate with technical team to align their requirements and help in development.

## Changelog

* v0.0.8 update for Rails 5

## Prerequisites

These versions works for sure but others may do.

* Ruby 2.4.1
* Rails 5.1.0.rc2
* MongoDB 6
* Freemind 1.0.1

## Convention

* database is MongoDB
* images stored in upload directory, unset IMAGE_LOCATION in `initializer/mindapp.rb` to use Cloudinary
* mail use Gmail SMTP, config in `config/application.rb`
* authentication use omniauth-identity

## Sample Application

Supposed we want to create ecommerce web site, first create a Rails
app without ActiveRecord

    $ rails new shop --skip-test-unit --skip-bundle --skip-active-record

## Add mindapp to your Gemfile:



For Development (most updated)
    gem 'mindapp', github:'kul1/mindapp'

For Original 
    gem 'mindapp'
       

depend on your operating system, you may need to uncomment

    gem 'therubyracer', :platforms => :ruby

install gems

    $ bundle

generate mindapp application

    $ rails generate mindapp:install

Then run bundle again to install additional gems added by mindapp

    $ bundle

configure mongoid

    $ rails generate mindapp:mongoid

    Please make sure mongod is running then create admin user

    $ rake mindapp:seed

now the application is ready, start it as any Rails application

    $ rails server

go to http://localhost:3000, click *Sign In* on the left menu, and enter user name `admin` and password `secret`

![home](https://cloud.githubusercontent.com/assets/3953832/25599624/deab1cee-2f07-11e7-8058-ef67a429e874.png)


Now open file `app/mindapp/index.mm` using Freemind

![index mm](https://cloud.githubusercontent.com/assets/3953832/25599716/90ea1c84-2f08-11e7-8240-dac26742862d.png)

The 3 main branches are

* models - this defines all the models to use in the application
* services - this defines services which will be come the menu on the left of the screen. There will be 2 levels; the first sub branch is the main menu (modules) and the second sub branch is the sub menu (services)
* roles - this defines role for all users

### models

Fiirst, we need to create some product so we click on models we'll see 2 models person and address. These are sample only. You can delete them or modify them however you want. We'll take a look at them first

![image](https://cloud.githubusercontent.com/assets/3953832/25599768/139e95ba-2f09-11e7-98df-21b6caf9b664.png)

The first sub branch (e.g. person) is the model name. According to Rails convention, this should be a singular word. The next sub branch are columns in the database. Let's take a look at each:

* `fname` - this create a column (field) called fname which is a String by default
* `sex: integer` - this create a column called sex, it is integer so must be explicity defined. The next sub branch (1: male) is disregarded by Mindapp so we can put whatever we want. Here I just put some reminder.
* `belongs_to :address` - here we have ![edit](http://songrit.googlecode.com/files/edit.png) icon. this means whatever text on this line will be added as is to the model Mindapp generates. You use this to specify anything you want such as  association, index, remarks in code, etc. according to mongoid gem. To draw the icon, rest mouse on the branch and hit &ltAlt-I&gt.
* `dob: date` - use any type that mongoid provides.
* `photo` - for file field, just use String here. Mindapp will receive the binary file and store in file system or cloudinary then generate a url link to it.

In this example we just want a product model, so delete the person and address model and add a product branch like so

![image](https://cloud.githubusercontent.com/assets/3953832/25599836/9bb82d58-2f09-11e7-9a26-c26a5d13c870.png)

Save the mind map then run:

    rake mindapp:update

This will create file `app/models/product.rb`. In this file, note the comment lines   `# mindapp begin` and ` # mindapp end`. Everything inside these comments will get overwritten when you change the models branch in the mind map so if you need to put anything inside here, use the mind map instead. You can add anything outside these comment lines which will be preserved when doing mindapp:update.

### services

Next we'll add some product into the database, we'll first take a look at the services branch, which already has 3 sub branches; users, admins, and devs. Unlike models person and address branches, these branches are actively used by the system so I recommend that you leave them alone. Let's open the users branch

![image](https://cloud.githubusercontent.com/assets/3953832/25599895/ecf46466-2f09-11e7-82aa-81ade6b9cd83.png)

The text `users:User` on the sub branch has these implications:

* `users` correspond to `app/controllers/users_controller.rb` which already exist when you do rails generate mindapp:install. New branch will create new controller if not exist. In Mindapp term, this will be called module.
* `User` will create entry in main menu on the left of the screen. You don't see it in the screenshot above because it's controlled by the sub branch `role:m` which means this menu only available for login member. If you already signed in as admin, you should see it now.

The next sub branches has the following:

* `role: m` - means that this module (menu) is available only to user who has role m (if you open the role branch now will see that role m is member). All registered user has role m by default. User who is not log on would not be able to access this module.
* `link:info: /users` - means that this is a link, the format is link: *submenu label* : *url* where submenu label is the text to show in the submenu and url is the link to go to, in this case, it woud go to http://localhost:3000/users which will perform index action of UsersController.
* `user:edit` the branch that do not start with role:, rule:, nor link: will be a Mindapp service. You will then specify the sequence of the execution as in this example there are 3 sub branches - enter_user, update_user, and rule:login? Let's take a look at them:

* `enter_user:edit` - the first step is to display a form to input user information, this is accompanied by icon ![image](https://cloud.githubusercontent.com/assets/3953832/25599946/47c32cf6-2f0a-11e7-80a8-2c02c6294c9a.png)
 which means user interface screen. and will correspond to a view file `app/views/users/user/enter_user.html.erb` where `/users` comes from the module name (the sub branch of services), `/user` comes from the service name (the sub branch of users), and `enter_user.html.erb` comes from the first part of this branch. The `edit` after the colon is just a description of this step. This branch also has sub branch `rule:login? && own_xmain?` which specify rule for this step that the user must be login and can continue this task if he is the one who started it. *task* in here means each instance of service.
* `update_user` - this icon ![image](https://cloud.githubusercontent.com/assets/3953832/25599976/87b69ad2-2f0a-11e7-9aba-1bd4e9546d3e.png) means to execute method update_user within `users_controller.rb`

Armed with this knowledge, we are ready to add new product into our application like so:

![products](http://songrit.googlecode.com/files/products.png)

To generate controller and views we save this mind map and run

    rake mindapp:update

open file `app/views/products/add/enter.html.erb` you'll see some sample view already in there but commented. edit the file so it look like this

![enter](http://songrit.googlecode.com/files/enter.png)

Note that we do not specify form_tag and submit_tag, these will be supplied by Mindapp.

then open file `app/controllers/products_controller.rb` and add `create` method as follow. The method name has to be correspond to the ![bookmark](http://songrit.googlecode.com/files/bookmark.png) branch.

![products_controller](http://songrit.googlecode.com/files/products_controller.png)


... to be continued ...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
