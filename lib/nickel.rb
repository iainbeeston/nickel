# Usage:
#
#   Nickel.parse "some query", Time.local(2011, 7, 1)
#
# The second term is optional.

require 'nickel/version'
require 'nickel/nlp'

module Nickel
  class << self
    def parse(query, date_time = Time.now)
      n = NLP.new(query, date_time)
      n.parse
      n
    end
  end
end
