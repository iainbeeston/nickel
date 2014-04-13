if ENV['TRAVIS'] && ENV['COVERALLS'] && RUBY_ENGINE == 'ruby'
  require 'coveralls'
  Coveralls.wear!
end

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.mock_with(:rspec) { |c| c.syntax = :expect }
  config.filter_run_excluding broken: true

  # make sure warnings are not shown when testing deprecated methods
  config.around(:each, :deprecated) do |example|
    original_verbose = $VERBOSE
    begin
      $VERBOSE = nil
      example.run
    ensure
      $VERBOSE = original_verbose
    end
  end
end
