# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rabbitmq_manager/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Carl Hörberg"]
  gem.email         = ["carl.hoerberg@gmail.com"]
  gem.description   = %q{Ruby wrapper for RabbitMQ management HTTP API}
  gem.summary       = %q{Ruby wrapper for RabbitMQ management HTTP API}
  gem.homepage      = "https://github.com/carlhoerberg/rabbitmq_manager"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "rabbitmq_manager"
  gem.require_paths = ["lib"]
  gem.version       = RabbitMQManager::VERSION

  gem.add_runtime_dependency 'faraday'
  gem.add_runtime_dependency 'faraday_middleware'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simple_cov'
end
