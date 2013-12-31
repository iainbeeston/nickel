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

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
