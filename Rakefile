require 'rake'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'coveralls/rake/task'
require 'yard'

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, 'coveralls:push']
