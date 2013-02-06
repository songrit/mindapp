# Mindapp

I like to develop application using Ruby on Rails. I find that most of my projects has some common tasks such as basic design, user administration, logging, workflow, etc. So I decide to use mind map to act as a language to explain what I want and have the tool generates the application that conform to standard framework so I can then customize everything later on. Mind map is used in design phase where it generates models and controller, in execution phase where it controls the work flow, and also use to generate documentation. System Analyst could use mind map to communicate with technical team to align their requirements and help in development.

## Prerequisites

* Ruby
* Rails
* MongoDB
* Freemind

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

To create model, open file `app/mindapp/index.mm`
![index.mm](http://songrit.googlecode.com/files/mm.png)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
