# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'lib/version'
 
Gem::Specification.new do |s|
  s.name         = "berlin-ai"
  s.version      = Berlin::AI::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Christian Blais", "Guillaume Malette", "Jodi Giordano"]
  s.email        = ["christ.blais@gmail.com", "gmalette@gmail.com", "giordano.jodi@gmail.com"]
  s.homepage     = "http://github.com/christianblais/berlin-ai"
  s.summary      = "Berlin Artificial Intelligence"
  s.description  = "Berlin Artificial Intelligence"
  
  s.add_dependency 'sinatra', '>=1.2.6'
  s.add_dependency 'yajl-ruby', '>=0.8.2'
  s.add_dependency 'sinatra-reloader', '>=0.5.0'
  
  s.files = [
    'LICENSE',
    'README',
    'berlin-ai.gemspec',
    'lib/berlin-ai.rb',
    'lib/version.rb',
    'lib/ai/game.rb',
    'lib/ai/map.rb',
    'lib/ai/node.rb',
    'test/test_ai.rb']
  
  s.require_paths = ['lib', 'test']
end
