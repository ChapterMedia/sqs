# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sqs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Piotr Sarnacki"]
  gem.email         = ["drogus@gmail.com"]
  gem.description   = %q{Simple Amazon SQS client}
  gem.summary       = %q{Simple Amazon SQS client}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "sqs"
  gem.require_paths = ["lib"]
  gem.version       = Sqs::VERSION

  gem.add_dependency "faraday", "~> 0.8"
  gem.add_dependency "nokogiri"

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'timecop'
end
