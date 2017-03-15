module Mindapp
  module Generators
    class MongoidGenerator < Rails::Generators::Base
      desc "Set up mongoid config"
      def setup_mongoid
        generate "mongoid:config"
        inject_into_file 'config/mongoid.yml', :after => '  # raise_not_found_error: true' do
          "\n    raise_not_found_error: false"
        end  
        inject_into_file 'config/mongoid.yml', :after => '  # app_name: MyApplicationName' do
          "\nproduction:" +
          "\n  clients:" +
          "\n    default:" +
          "\n      uri: <%= ENV['MONGODB_URI'] %>" + 
          "\n      options:" + 
          "\n        consistency: :strong"  
        end
      end
      def finish
        puts "Mongoid configured, please run rake mindapp:seed to set up admin/secret user, and may Set "
      end
    end
  end
end
