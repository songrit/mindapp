# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mindapp/version'

Gem::Specification.new do |gem|
  gem.name          = "mindapp"
  gem.version       = Mindapp::VERSION
  gem.authors       = ["Korakot Leemakdej"]
  gem.email         = ["songrit@gmail.com"]
  gem.summary       = %q{generate Ruby on Rails app from mind map}
  gem.description   = %q{generate Ruby on Rails app from mind map}
  gem.homepage      = "https://github.com/songrit/mindapp"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license  = 'MIT'

  # gem.add_dependency('mongo', '= 1.5.1')
  # gem.add_dependency('bson_ext', '= 1.5.1')
  # gem.add_dependency('mongoid')

  # gem.add_dependency('nokogiri') # for mindapp/doc
  # gem.add_dependency('haml-rails')
  # gem.add_dependency('mail')
  # gem.add_dependency('prawn')
  # gem.add_dependency('redcarpet')
  # gem.add_dependency('bcrypt-ruby', '=3.0.0')
  # gem.add_dependency('omniauth-identity')
  # gem.add_dependency('cloudinary')
  # gem.add_dependency('kaminari')
  # gem.add_development_dependency('debugger')
  # gem.add_development_dependency('rspec')
  # gem.add_development_dependency('rspec-rails')
  # gem.add_development_dependency('better_errors')
  # gem.add_development_dependency('binding_of_caller')
end
