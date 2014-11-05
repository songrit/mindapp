module Mindapp
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install mindapp component to existing Rails app "
      def self.source_root
        File.dirname(__FILE__) + "/templates"
      end

      def setup_routes
        route "root :to => 'mindapp#index'"
        # route "match '/mindapp/init/:module/:service(/:id)' => 'Mindapp#init'"

        route "resources :identities"
        route "resources :sessions"
        route "post '/auth/:provider/callback' => 'sessions#create'"
        route "get '/auth/failure' => 'sessions#failure'"
        route "get '/logout' => 'sessions#destroy', :as => 'logout'"
        route "get ':controller(/:action(/:id))(.:format)'"
      end

      def setup_env
        create_file 'README.md', ''
        # bug in mongo ruby driver 1.6.1, wait for mongoid 2.4.7
        # gem "mongo", "1.5.1"
        # gem "bson_ext", "1.5.1"
        # gem "mongoid"
        # run "bundle install"
        # generate "rspec:install"
        inject_into_file 'config/application.rb', :after => 'require "active_resource/railtie"' do
          "\nrequire 'mongoid/railtie'\n"
          "\nrequire 'rexml/document'\n"
        end
        application do
%q{
  # Mindapp default
  config.generators do |g|
    g.orm             :mongoid
    g.template_engine :haml
    g.test_framework  :rspec
    g.integration_tool :rspec
  end
  # gmail config
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :user_name            => 'user@gmail.com',
    :password             => 'secret',
    :authentication       => 'plain',
    :enable_starttls_auto => true  }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
}
        end
        initializer "mindapp.rb" do
%q{# encoding: utf-8
MM = "#{Rails.root}/app/mindapp/index.mm"
DEFAULT_TITLE = 'Mindapp'
DEFAULT_HEADER = 'Mindapp'
GMAP = true
NEXT = "Next >"
# comment IMAGE_LOCATION to use cloudinary (specify params in config/cloudinary.yml)
IMAGE_LOCATION = "upload"
# for debugging
# DONT_SEND_MAIL = true
}
        end

        inject_into_file 'config/environment.rb', :after => "initialize!"  do
          "\n\n# hack to fix cloudinary error https://github.com/archiloque/rest-client/issues/141" +
          "\nclass Hash\n  remove_method :read\nrescue\nend"
        end
        inject_into_file 'config/environments/development.rb', :after => 'config.action_mailer.raise_delivery_errors = false' do
          "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
        end
        inject_into_file 'config/environments/production.rb', :after => 'config.assets.compile = false' do
          "\n  config.assets.compile = true"
        end
      end

      def setup_omniauth
        # gem 'bcrypt-ruby', '~> 3.0.0'
        # gem 'omniauth-identity'
        initializer "omniauth.rb" do
%q{
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity,
    :fields => [:code, :email],
    :on_failed_registration=> lambda { |env|
      IdentitiesController.action(:new).call(env)
  }
end
}
        end
      end

      def setup_app
        inside("public") { run "mv index.html index.html.bak" }
        inside("app/views/layouts") { run "mv application.html.erb application.html.erb.bak" }
        inside("app/assets/javascripts") { run "mv application.js application.js.bak" }
        inside("app/assets/stylesheets") { run "mv application.css application.css.bak" }
        directory "app"
      end

      def gen_user
        # copy_file "seeds.rb","db/seeds.rb"
      end

      def gen_image_store
        copy_file "cloudinary.yml","config/cloudinary.yml"
        empty_directory "upload" # create upload directory just in case
      end

      def setup_gems
        gem "mongo"
        gem "bson_ext"
        # gem "mongo", '1.5.1'
        # gem "bson_ext", '1.5.1'
        # for Rails 4
        gem 'mongoid', '~> 4.0.0'
        # gem "mongoid"
        gem "nokogiri" # use for mindapp/doc
        # gem "rmagick", :require => "RMagick", :platform => "ruby"
        gem 'haml-rails'
        gem "mail"
        gem "prawn"
        gem "redcarpet"
        gem 'bcrypt-ruby', '~> 3.0.0'
        gem 'omniauth-identity'
        gem 'cloudinary'
        gem 'kaminari'
        gem_group :development, :test do
          gem "debugger"
          gem "rspec"
          gem "rspec-rails"
          gem "better_errors"
          gem "binding_of_caller"
        end
      end

      def finish
        puts "Mindapp installation finish, please run bundle install again to install additional gems. Then run rails generate mindapp:mongoid"
      end

    end
  end
end
