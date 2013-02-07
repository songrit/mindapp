# Mindapp

I like to develop application using Ruby on Rails. I find that most of my projects has some common tasks such as basic design, user administration, logging, workflow, etc. So I decide to use mind map to act as a language to explain what I want and have the tool generates the application that conform to standard framework so I can then customize everything later on. Mind map is used in design phase where it generates models and controller, in execution phase where it controls the work flow, and also use to generate documentation. System Analyst could use mind map to communicate with technical team to align their requirements and help in development.

## Prerequisites

* Ruby 1.9
* Rails 3.2
* MongoDB
* Freemind 0.9

## Convention

* database is MongoDB
* images stored in or Cloudinary by default, set IMAGE_LOCATION in `initializer/mindapp.rb` to use file system
* mail use Gmail SMTP, set up credential in `config/application.rb`
* authentication use omniauth-identity
* use Rspec for test

## Installation

Create Rails app without ActiveRecord

    $ rails new app --skip-test-unit --skip-bundle --skip-active-record

Add this line to your application's Gemfile:

    gem 'mindapp'

you may also need to enable gem `therubyracer` as well, then execute:

    $ bundle

Then generate and seed (you will be asked to overwrite `db/seeds.rb`) , which will create initial user admin:secret

    $ rails generate mindapp:install
    $ bundle
    $ rake db:seed

Your app is now ready at http://localhost:3000/.

    $ rails server

When make changes to app/mindapp/index.mm, run

    $ rake mindapp:update

## Sample Application

Supposed we want to create ecommerce web site

    $ rails new shop --skip-test-unit --skip-bundle --skip-active-record

edit Gemfile:

    gem 'mindapp', :git => "git://github.com/songrit/mindapp.git"

depend on your operating system, you may need to uncomment

    gem 'therubyracer', :platforms => :ruby

install gems

    $ bundle

generate mindapp application

    $ rails generate mindapp:install

it will ask to overwrite the seeds.rb file, enter y, then run bundle again to install additional gems added by mindapp

The next step is create admin user

    $ rake db:seed

now the application is ready, start it as any Rails application

    $ rails server

go to http://localhost:3000, click *Sign In* on the left menu, and enter user name `admin` and password `secret`

Now open file `app/mindapp/index.mm` using Freemind
![index.mm](http://songrit.googlecode.com/files/mm.png)

The 3 main branches are

* models - this defines all the models to use in the application
* services - this defines services which will be come the menu on the left of the screen. There will be 2 levels; the first sub branch is the main menu (modules) and the second sub branch is the sub menu (services)
* roles - this defines role for all users

Fiirst, we need to create some product so we click on models we'll see 2 models person and address. These are sample only. You can delete them or modify them however you want. We'll take a look at them first

![models](http://songrit.googlecode.com/files/models.png)

The first sub branch (e.g. person) is the model name. According to Rails convention, this should be a singular word. The next sub branch are columns in the database. Let's take a look at each:

* fname - this create a column (field) called fname which is a String by default
* sex: integer - this create a column called sex, it is integer so must be explicity defined. The next sub branch (1: male) is disregarded by Mindapp so we can put whatever we want. Here I just put some reminder.
* belongs_to :address - here we have this ![edit](http://songrit.googlecode.com/files/edit.png) icon. this means whatever text on this line will be added as is to the model Mindapp generates. You use this to specify anything you want such as  association, index, remarks in code, etc. according to mongoid gem. To draw the icon, rest mouse on the branch and hit <Alt-I>
* dob: date - use any type that mongoid has
* photo - for file field, just use String here. Mindapp will receive the binary file and store in file system or cloudinary then generate a link to it.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
