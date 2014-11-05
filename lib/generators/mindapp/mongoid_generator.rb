module Mindapp
  module Generators
    class MongoidGenerator < Rails::Generators::Base
      desc "Set up mongoid config"
      def setup_mongoid
        generate "mongoid:config"
        inject_into_file 'config/mongoid.yml', :after => '  # raise_not_found_error: true' do
          "\n    raise_not_found_error: false"
        end
      end
      def finish
        puts "Mongoid configured, please run rake mindapp:seed to set up admin/secret user"
      end

    end
  end
end
