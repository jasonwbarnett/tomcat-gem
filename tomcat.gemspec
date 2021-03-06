# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tomcat/version'

Gem::Specification.new do |spec|
  spec.name          = "tomcat"
  spec.version       = Tomcat::VERSION
  spec.authors       = ["Jason Barnett"]
  spec.email         = ["jason.w.barnett@gmail.com"]
  spec.summary       = %q{Query Tomcat server.xml and it's services.}
  spec.homepage      = "https://github.com/jasonwbarnett/tomcat-gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "nokogiri", "~> 1.6.5"
end
