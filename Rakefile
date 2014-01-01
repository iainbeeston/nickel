require 'rake'
require "bundler/gem_tasks"
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'
require 'yard'

task :default => [:test, :spec]

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

Coveralls::RakeTask.new
task :test_with_coveralls => [:test, :spec, 'coveralls:push']
