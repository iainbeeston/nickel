# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nickel/version'

Gem::Specification.new do |s|
  s.name               = "nickel"
  s.version            = Nickel::VERSION
  s.summary            = "Natural language date, time, and message parsing."
  s.homepage           = "http://github.com/iainbeeston/nickel"
  s.description        = "Extracts date, time, and message information from naturally worded text."
  s.has_rdoc           = true
  s.license            = "MIT"
  s.authors            = ["Lou Zell", "Iain Beeston"]

  s.files              = `git ls-files`.split($/)
  s.test_files         = s.files.grep(%r{^(test|spec)/})
  s.require_paths      = ["lib"]

  if RUBY_ENGINE == 'rbx'
    s.add_dependency 'rubysl-logger'
    s.add_dependency 'rubysl-date'
    s.add_development_dependency 'rubysl-rake'
    s.add_development_dependency 'rubysl-bundler'
  end

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "3.0.0.beta1"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "yard"
  s.add_development_dependency "kramdown"
end
