require 'nickel/zdate'
require 'nickel/ztime'
require 'nickel/nlp_query_constants'
require 'nickel/substitutions/formatting'
require 'nickel/substitutions/standardization'
require 'nickel/substitutions/pre_processing'

module Nickel
  class NLPQuery
    include NLPQueryConstants

    def initialize(query_str)
      @query_str = query_str.dup
      @changed_in = []
    end

    attr_reader :after_formatting, :changed_in

    def standardize
      @query = query_str.dup # needed for case correcting after extract_message has been called
      query_formatting  # easy text manipulation, no regex involved here
      query_pre_processing  # puts query in the form that construct_finder understands, lots of manipulation here
      query_str.dup
    end

    def query_formatting
      query_str.downcase!
      Substitutions::Formatting.apply(self)
      Substitutions::Standardization.apply(self)
      query_str.concat(' ')
      @after_formatting = query_str.dup    # save current state
    end

    # Usage:
    #   self.nsub!(/foo/, 'bar')
    #
    # nsub! is like gsub! except it logs the calling method in @changed_in.
    # There is another difference: When using blocks, matched strings are
    # available as block params, e.g.: # nsub!(/(match1)(match2)/) {|m1,m2|}
    #
    # I wrote this because I was having problems overriding gsub and passing
    # a block from the new gsub to super.
    def nsub!(*args)
      if m = query_str.match(args[0])    # m will now hold the FIRST set of backreferenced matches
        # there is at least one match
        @changed_in << caller[1]
        if block_given?
          # query_str.gsub!(args[0]) {yield(*m.to_a[1..-1])}    # There is a bug here: If gsub matches more than once,
                                                      # then the first set of referenced matches will be passed to the block
          ret_str = m.pre_match + m[0].sub(args[0]) { yield(*m.to_a[1..-1]) }   # this will take care of the first set of matches
          while (m_old = m.dup) && (m = m.post_match.match(args[0]))
            ret_str << m.pre_match + m[0].sub(args[0]) { yield(*m.to_a[1..-1]) }
          end
          ret_str << m_old.post_match
          query_str.sub!(/.*/, ret_str)
        else
          query_str.gsub!(args[0], args[1])
        end
      end
    end

    def query_pre_processing
      Substitutions::PreProcessing.apply(self)

      # 'the' cases; what this is all about is if someone enters "first sunday of the month" they mean one date.  But if someone enters "first sunday of the month until december 2nd" they mean recurring
      # Do these actually do ANYTHING anymore?
      # "on the 3rd sat and sunday of the month" --> "repeats monthly 3rd sat 3rd sun"  OR  "3rd sat this month 3rd sun this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD.source}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) do |m1, m2|
            'repeats monthly ' + m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK.source}/, m1 + ' \1')
          end
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) do |m1, m2|
            m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK.source}/, m1 + ' \1 this month')
          end
        end
      end

      # "on the 2nd and 3rd sat of this month" --> "repeats monthly 2nd sat 3rd sat"  OR  "2nd sat this month 3rd sat this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD.source}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:the)\s+month/) do |m1, m2|
            'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2)
          end
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:the)\s+month/) do |m1, m2|
            m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month')
          end
        end
      end

      # "on the 3rd sat and 5th tuesday of this month" --> "repeats monthly 3rd sat 5th tue" OR "3rd sat this month 5th tuesday this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD.source}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) do |m1|
            'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '')
          end
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) do |m1|
            m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK.source}/, '\1 this month')
          end
        end
      end
    end

    def to_s
      query_str
    end

    private

    attr_accessor :query_str
  end
end
