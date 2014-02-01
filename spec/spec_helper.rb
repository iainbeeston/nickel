if ENV['TRAVIS'] && ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear_merged!
end

RSpec.configure do |config|
  config.order = 'random'
  config.expect_with(:rspec){ |c| c.syntax = :expect }
  config.mock_with(:rspec){ |c| c.syntax = :expect }
end
