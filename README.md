# Mindapp

gem to generate ror app from mind map

## Convention

  * database is MongoDB
  * images stored in or Cloudinary (default) unset IMAGE_LOCATION in initializer/mindapp.rb to use file system
  * mail use Gmail SMTP
  * authentication use omniauth-identity

## Installation

Add this line to your application's Gemfile:

    gem 'mindapp'

And then execute:

    $ bundle

Then

  $ rails generate mindapp:install
  $ rake db:seed, will create initial user admin:secret

When make changes to app/mindapp/index.mm, run

  $ rake mindapp:update

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
