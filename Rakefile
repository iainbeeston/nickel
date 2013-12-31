require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => [:test, :spec]

desc 'Test the nlp plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

RSpec::Core::RakeTask.new(:spec)

desc 'Generate documentation for the nlp plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Nlp'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
