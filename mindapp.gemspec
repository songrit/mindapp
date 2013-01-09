# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mindapp/version'

Gem::Specification.new do |gem|
  gem.name          = "mindapp"
  gem.version       = Mindapp::VERSION
  gem.authors       = ["songrit"]
  gem.email         = ["songrit@gmail.com"]
  gem.description   = %q{generate ror app from mind map}
  gem.summary       = %q{generate ror app from mind map}
  gem.homepage      = "https://github.com/songrit/mindapp"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
