# coding: utf-8
require File.expand_path('../lib/corefines/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'corefines'
  s.version       = Corefines::VERSION
  s.author        = 'Jakub Jirutka'
  s.email         = 'jakub@jirutka.cz'
  s.homepage      = 'https://github.com/jirutka/corefines'
  s.license       = 'MIT'

  s.summary       = 'A collection of refinements for Ruby core classes.'
  s.description   = <<-EOS
Corefines is a collection of general purpose refinements for extending the core
capabilities of Ruby's built-in classes. It also provides a compatibility mode
for older Ruby versions and alternative Ruby implementations that
doesn't support refinements (yet).
  EOS

  begin
    s.files       = `git ls-files -z -- */* {LICENSE,Rakefile,README}*`.split("\x0")
  rescue
    s.files       = Dir['**/*']
  end

  s.require_paths = ['lib']
  s.has_rdoc      = 'yard'

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency 'asciidoctor', '~> 1.5.0'  # needed for yard
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'yard', '~> 0.8'
end
