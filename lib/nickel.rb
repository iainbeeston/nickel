# Ruby Nickel Library
# Copyright (c) 2008-2011 Lou Zell, lzell11@gmail.com, http://hazelmade.com
# MIT License [http://www.opensource.org/licenses/mit-license.php]
#
# Usage:
#
#   Nickel.parse "some query", Time.local(2011, 7, 1)
#
# The second term is optional.

require_relative 'nickel/nlp'

module Nickel
  class << self
    def parse(query, date_time = Time.now)
      n = NLP.new(query, date_time)
      n.parse
      n
    end
  end
end
