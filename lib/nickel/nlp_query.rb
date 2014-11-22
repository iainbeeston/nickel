require 'nickel/zdate'
require 'nickel/ztime'
require 'nickel/nlp_query_constants'
require 'nickel/substitutions/formatting'
require 'nickel/substitutions/standardization'

module Nickel
  class NLPQuery
    include NLPQueryConstants

    def initialize(query_str)
      @query_str = query_str.dup
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
        @changed_in ||= []
        @changed_in << caller[1][/(\w+)\W*$/, 1]
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
      standardize_input
    end

    def to_s
      query_str
    end

    private

    attr_accessor :query_str

    def standardize_input
      nsub!(/last\s+#{DAY_OF_WEEK}/, '5th \1')     # last dayname  =>  5th dayname
      nsub!(/\ba\s+(week|month|day)/, '1 \1')     # a month|week|day  =>  1 month|week|day
      nsub!(/^(through|until)/, 'today through')   # ^through  =>  today through
      nsub!(/every\s*(night|morning)/, 'every day')
      nsub!(/tonight/, 'today')
      nsub!(/this(?:\s*)morning/, 'today')
      nsub!(/before\s+12pm/, '6am to 12pm')        # arbitrary

      # Handle 'THE' Cases
      # Attempt to pick out where a user entered 'the' when they really mean 'every'.
      # For example,
      # The first of every month and the 22nd of THE month  =>  repeats monthly first xxxxxx repeats monthly 22nd xxxxxxx
      nsub!(/(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+(?:of\s+)?(?:every|each)\s+month((?:.*)of\s+the\s+month(?:.*))/) do |m1, m2|
        ret_str = ' repeats monthly ' + m1
        ret_str << m2.gsub(/(?:and\s+)?(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+of\s+the\s+month/, ' repeats monthly \1 ')
      end

      # Every first sunday of the month and the last tuesday  =>  repeats monthly first sunday xxxxxxxxx repeats monthly last tuesday xxxxxxx
      nsub!(/every\s+#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}\s+of\s+(?:the\s+)?month((?:.*)and\s+(?:the\s+)?#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}(?:.*))/) do |m1, m2, m3|
        ret_str = ' repeats monthly ' + m1 + ' ' + m2 + ' '
        ret_str << m3.gsub(/and\s+(?:the\s+)?#{WEEK_OF_MONTH}\s+#{DAY_OF_WEEK}(?:\s*)(?:of\s+)?(?:the\s+)?(?:month\s+)?/, ' repeats monthly \1 \2 ')
      end

      # The x through the y of oct z  =>  10/x/z through 10/y/z
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD}\s(?:of\s+)#{MONTH_OF_YEAR}\s+(?:of\s+)?#{YEAR}/) do |m1, m2, m3, m4|
        (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + '/' + m4 + ' through ' +  (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2 + '/' + m4
      end

      # The x through the y of oct  =>  10/x through 10/y
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:through|to|until)\s+(?:the\s+)#{DATE_DD}\s(?:of\s+)?#{MONTH_OF_YEAR}/) do |m1, m2, m3|
        (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2
      end

      # January 1 - February 15
      nsub!(/#{MONTH_OF_YEAR}\s+#{DATE_DD_NB_ON_SUFFIX}\s+(?:through|to|until)\s+#{MONTH_OF_YEAR}\s#{DATE_DD_NB_ON_SUFFIX}/) do |m1, m2, m3, m4|
        (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2.gsub(/(st|nd|rd|th)/, '') + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4.gsub(/(st|nd|rd|th)/, '')
      end

      # Tuesday, january 1 - friday, february 15, 2013
      nsub!(/(?:#{DAY_OF_WEEK})?(?:[\s,]+)#{MONTH_OF_YEAR}(?:[\s,]+)#{DATE_DD}\s+(?:through|to|until)\s+(?:#{DAY_OF_WEEK})?(?:[\s,]+)#{MONTH_OF_YEAR}(?:[\s,]+)#{DATE_DD}(?:[\s,]+)#{YEAR}/) do |m1, m2, m3, m4, m5, m6, m7|
        if m7.nil?
          (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3.gsub(/(st|nd|rd|th)/, '') + ' through ' + (ZDate.months_of_year.index(m5) + 1).to_s + '/' + m6
        else
          (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3.gsub(/(st|nd|rd|th)/, '') + '/' + m7 + ' through ' + (ZDate.months_of_year.index(m5) + 1).to_s + '/' + m6.gsub(/(st|nd|rd|th)/, '') + '/' + m7
        end
      end

      # Tuesday, january 1 2013 - friday, february 15, 2013
      nsub!(/(?:#{DAY_OF_WEEK})?(?:[\s,]+)#{MONTH_OF_YEAR}(?:[\s,]+)#{DATE_DD}\s+#{YEAR}\s+(?:through|to|until)\s+(?:#{DAY_OF_WEEK})?(?:[\s,]+)#{MONTH_OF_YEAR}(?:[\s,]+)#{DATE_DD}(?:[\s,]+)#{YEAR}/) do |m1, m2, m3, m4, m5, m6, m7, m8|
        (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3 + '/' + m4 + ' through ' + (ZDate.months_of_year.index(m6) + 1).to_s + '/' + m7 + '/' + m8
      end

      # Monthname x through y
      nsub!(/#{MONTH_OF_YEAR}\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX}\s+(?:of\s+)?(?:#{YEAR}\s+)?(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX}(?:\s+of)?(?:\s+#{YEAR})?/) do |m1, m2, m3, m4, m5|
        if m3  # $3 holds first occurrence of year
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m3 + ' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4 + '/' + m3
        elsif m5 # $5 holds second occurrence of year
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m5 + ' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4 + '/' + m5
        else
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + ' through ' + (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m4
        end
      end

      # Monthname x through monthname y
      # Jan 14 through jan 18  =>  1/14 through 1/18
      # Oct 2 until oct 5
      nsub!(/#{MONTH_OF_YEAR}\s+#{DATE_DD_NB_ON_SUFFIX}\s+(?:to|through|until)\s+#{MONTH_OF_YEAR}\s+#{DATE_DD_NB_ON_SUFFIX}\s+(?:of\s+)?(?:#{YEAR})?/) do |m1, m2, m3, m4, m5|
        if m5
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m5 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + '/' + m5 + ' '
        else
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + ' '
        end
      end

      # Mnday the 23rd, tuesday the 24th and wed the 25th of oct  =>  11/23 11/24 11/25
      nsub!(/((?:#{DAY_OF_WEEK_NB}\s+the\s+#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?){1,31})of\s+#{MONTH_OF_YEAR}\s*(#{YEAR})?/) do |m1, m2, m3|
        month_str = (ZDate.months_of_year.index(m2) + 1).to_s
        if m3
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
        else
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1')
        end
      end

      # the 23rd and 24th of october                    =>  11/23 11/24
      # the 23rd, 24th, and 25th of october             =>  11/23 11/24 11/25
      # the 23rd, 24th, and 25th of october 2010        =>  11/23/2010 11/24/2010 11/25/2010
      # monday and tuesday, the 23rd and 24th of july   =>  7/23 7/24
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:day\s+)?(?:in\s+)?(?:of\s+)#{MONTH_OF_YEAR}\s*(#{YEAR})?/) do |m1, m2, m3|
        month_str = (ZDate.months_of_year.index(m2) + 1).to_s
        if m3
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
        else
          m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1')
        end
      end

      # Match date with year first.
      # Don't allow mixing of suffixes, e.g. "dec 3rd 2008 at 4 and dec 5 2008 9 to 5"
      # Dec 2nd, 3rd, and 5th 2008  => 12/2/2008 12/2/2008 12/5/2008
      # Mon nov 23rd 08
      # Dec 2, 3, 5, 2008  =>  12/2/2008 12/3/2008 12/5/2008
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+((?:(?:the\s+)?#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?){1,31})#{YEAR}/) do |m1, m2, m3|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/\b(and|the)\b/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/, month_str + '/\1/' + m3)
      end

      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+((?:(?:the\s+)?#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?){1,31})#{YEAR}/) do |m1, m2, m3|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/\b(and|the)\b/, '').gsub(/#{DATE_DD_WITHOUT_SUFFIX}/, month_str + '/\1/' + m3)
      end

      # Dec 2nd, 3rd, and 4th  =>  12/2, 12/3, 12/4
      # Note: dec 5 9 to 5 will give an error, need to find these and convert to dec 5 from 9 to 5; also dec 3,4, 9 to|through 5 --> dec 3, 4 from 9 through 5
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1, m2|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/(and|the)/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/) { month_str + '/' + Regexp.last_match(1) }  # last match is from the nested match!
      end

      # Apr 29, 5 - 8pm
      nsub!(/#{MONTH_OF_YEAR}(?:\s)+#{DATE_DD_WITHOUT_SUFFIX}(?:,)?(?:\s)+(#{TIME} through #{TIME})/) do |m1, m2, m3|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        "#{month_str}/#{m2} #{m3}"
      end

      # jan 4 2-3 has to be modified, but
      # jan 24 through jan 26 cannot!
      # not real sure what this one is doing
      # "dec 2, 3, and 4" --> 12/2, 12/3, 12/4
      # "mon, tue, wed, dec 2, 3, and 4" --> 12/2, 12/3, 12/4
      nsub!(/(#{MONTH_OF_YEAR_NB}\s+(?:the\s+)?(?:(?:#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:to|through|until)\s+#{DATE_DD_WITHOUT_SUFFIX_NB})/) { |m1| m1.gsub(/#{DATE_DD_WITHOUT_SUFFIX}\s+(to|through|until)/, 'from \1 through ') }
      nsub!(/(?:(?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR}\s+(?:the\s+)?((?:#{DATE_DD_WITHOUT_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1, m2|
        month_str = (ZDate.months_of_year.index(m1) + 1).to_s
        m2.gsub(/(and|the)/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX}/) { month_str + '/' + Regexp.last_match(1) }  # last match is from nested match
      end

      # "monday 12/6" --> 12/6
      nsub!(/#{DAY_OF_WEEK_NB}\s+(#{DATE_MM_SLASH_DD})/, '\1')

      # "next friday to|until|through the following tuesday" --> 10/12 through 10/16
      # "next friday through sunday" --> 10/12 through 10/14
      # "next friday and the following sunday" --> 11/16 11/18
      # we are not going to do date calculations here anymore, so instead:
      # next friday to|until|through the following tuesday" --> next friday through tuesday
      # next friday and the following sunday --> next friday and sunday
      nsub!(/next\s+#{DAY_OF_WEEK}\s+(to|until|through|and)\s+(?:the\s+)?(?:following|next)?(?:\s*)#{DAY_OF_WEEK}/) do |m1, m2, m3|
        connector = (m2 =~ /and/ ? ' ' : ' through ')
        'next ' + m1 + connector + m3
      end

      # "this friday to|until|through the following tuesday" --> 10/5 through 10/9
      # "this friday through following sunday" --> 10/5 through 10/7
      # "this friday and the following monday" --> 11/9 11/12
      # No longer performing date calculation
      # this friday and the following monday --> fri mon
      # this friday through the following tuesday --> fri through tues
      nsub!(/(?:this\s+)?#{DAY_OF_WEEK}\s+(to|until|through|and)\s+(?:the\s+)?(?:this|following)(?:\s*)#{DAY_OF_WEEK}/) do |m1, m2, m3|
        connector = (m2 =~ /and/ ? ' ' : ' through ')
        m1 + connector + m3
      end

      # "the wed after next" --> 2 wed from today
      nsub!(/(?:the\s+)?#{DAY_OF_WEEK}\s+(?:after|following)\s+(?:the\s+)?next/, '2 \1 from today')

      # "mon and tue" --> mon tue
      nsub!(/(#{DAY_OF_WEEK}\s+and\s+#{DAY_OF_WEEK})(?:\s+and)?/, '\2 \3')

      # "mon wed every week" --> every mon wed
      nsub!(/((#{DAY_OF_WEEK}(?:\s*)){1,7})(?:of\s+)?(?:every|each)(\s+other)?\s+week/, 'every \4 \1')

      # "every 2|3 weeks" --> every 2nd|3rd week
      nsub!(/(?:repeats\s+)?every\s+(2|3)\s+weeks/) { |m1| 'every ' + m1.to_i.ordinalize + ' week' }

      # "every week on mon tue fri" --> every mon tue fri
      nsub!(/(?:repeats\s+)?every\s+(?:(other|3rd|2nd)\s+)?weeks?\s+(?:\bon\s+)?((?:#{DAY_OF_WEEK_NB}\s+){1,7})/, 'every \1 \2')

      # "every mon and every tue and.... " --> every mon tue ...
      nsub!(/every\s+#{DAY_OF_WEEK}\s+(?:and\s+)?every\s+#{DAY_OF_WEEK}(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK})?/, 'every \1 \2 \3 \4 \5')

      # monday, wednesday, and friday next week at 8
      nsub!(/((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){1,7})(?:of\s+)?(this|next)\s+week/, '\2 \1')

      # "every day this|next week"  --> returns monday through friday of the closest week, kinda stupid
      # doesn't do that anymore, no date calculations allowed here, instead just formats it nicely for construct finders --> every day this|next week
      nsub!(/every\s+day\s+(?:of\s+)?(this|the|next)\s+week\b./) { |m1| m1 == 'next' ? 'every day next week' : 'every day this week' }

      # "every day for the next week" --> "every day this week"
      nsub!(/every\s+day\s+for\s+(the\s+)?(next|this)\s+week/, 'every day this week')

      # "this weekend" --> sat sun
      nsub!(/(every\s+day\s+|both\s+days\s+)?this\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/, 'sat sun')

      # "this weekend including mon" --> sat sun mon
      nsub!(/sat\s+sun\s+(and|includ(es?|ing))\s+mon/, 'sat sun mon')
      nsub!(/sat\s+sun\s+(and|includ(es?|ing))\s+fri/, 'fri sat sun')

      # Note: next weekend including monday will now fail.  Need to make constructors find "next sat sun mon"
      # "next weekend" --> next weekend
      nsub!(/(every\s+day\s+|both\s+days\s+)?next\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/, 'next weekend')

      # "next weekend including mon" --> next sat sun mon
      nsub!(/next\s+weekend\s+(and|includ(es?|ing))\s+mon/, 'next sat sun mon')
      nsub!(/next\s+weekend\s+(and|includ(es?|ing))\s+fri/, 'next fri sat sun')

      # "every weekend" --> every sat sun
      nsub!(/every\s+weekend(?:\s+(?:and|includ(?:es?|ing))\s+(mon|fri))?/, 'every sat sun' + ' \1')  # regarding "every sat sun fri", order should not matter after "every" keyword

      # "weekend" --> sat sun     !!! catch all
      nsub!(/weekend/, 'sat sun')

      # "mon through wed" -- >  mon tue wed
      # CATCH ALL FOR SPANS, TRY NOT TO USE THIS
      nsub!(/#{DAY_OF_WEEK}\s+(?:through|to|until)\s+#{DAY_OF_WEEK}/) do |m1, m2|
        index1 = ZDate.days_of_week.index(m1)
        index2 = ZDate.days_of_week.index(m2)
        i = index1
        ret_string = ''
        if index2 > index1
          while i <= index2
            ret_string << ZDate.days_of_week[i] + ' '
            i += 1
          end
        elsif index2 < index1
          loop do
            ret_string << ZDate.days_of_week[i] + ' '
            i = (i + 1) % 7
            break if i != index2 + 1     # wrap until it hits index2
          end
        else
          # indices are the same, one week event
          8.times do
            ret_string << ZDate.days_of_week[i] + ' '
            i = (i + 1) % 7
          end
        end
        ret_string
      end

      # "every day" --> repeats daily
      nsub!(/\b(repeat(?:s|ing)?|every|each)\s+da(ily|y)\b/, 'repeats daily')

      # "every other week starting this|next fri" --> every other friday starting this friday
      nsub!(/every\s+(3rd|other)\s+week\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+#{DAY_OF_WEEK}/, 'every \1 \3 start \2 \3')

      # "every other|3rd friday starting this|next week" --> every other|3rd friday starting this|next friday
      nsub!(/every\s+(3rd|other)\s+#{DAY_OF_WEEK}\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+week/, 'every \1 \2 start \3 \2')

      # "repeats monthly on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
      # "repeats every other month on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
      # "repeats every three months on the 1st and 2nd friday" --> repeats threemonthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)          { |m1, m2| 'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/) { |m1, m2| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)           { |m1, m2| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)          { |m1, m2| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/) { |m1, m2| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}/)           { |m1, m2| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }

      # "repeats monthly on the 1st friday" --> repeats monthly 1st friday
      # "repeats monthly on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
      # "repeats every other month on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)                 { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)           { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)                 { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/) { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})/)           { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "repeats monthly on the 1st friday saturday" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)                  { |m1, m2| 'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)  { |m1, m2| 'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)            { |m1, m2| 'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)                  { |m1, m2| 'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)  { |m1, m2| 'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})/)            { |m1, m2| 'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }

      # "21st of each month" --> repeats monthly 21st
      # "on the 21st, 22nd and 25th of each month" --> repeats monthly 21st 22nd 25th
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+\bmonths?/)                  { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+(?:other|2n?d?)\s+months?/)  { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+3r?d?\s+months?/)            { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "repeats each month on the 22nd" --> repeats monthly 22nd
      # "repeats monthly on the 22nd 23rd and 24th" --> repeats monthly 22nd 23rd 24th
      # This can ONLY handle multi-day recurrence WITHOUT independent times for each, i.e. "repeats monthly on the 22nd at noon and 24th from 1 to 9"  won't work; that's going to be a tricky one.
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
     # nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonthly\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
     # nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
      nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
     # nsub!(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}

      # "on day 4 of every month" --> repeats monthly 4
      # "on days 4 9 and 14 of every month" --> repeats monthly 4 9 14
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+\bmonths?/) { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+(?:other|2n?d?)\s+months?/) { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+3r?d?\s+months?/) { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "every 22nd of the month" --> repeats monthly 22
      # "every 22nd 23rd and 25th of the month" --> repeats monthly 22 23 25
      nsub!(/(?:repeats\s+)?(?:every|each)\s+((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:every|each)\s+other\s+((?:#{DATE_DD_WITH_SUFFIX_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "every 1st and 2nd fri of the month" --> repeats monthly 1st fri 2nd fri
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) { |m1, m2| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) { |m1, m2| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }

      # "every 1st friday of the month" --> repeats monthly 1st friday
      # "every 1st friday and 2nd tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "every 1st fri sat of the month" --> repeats monthly 1st fri 1st sat
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)          { |m1, m2| 'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:each|every|all)\s+other\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/)  { |m1, m2| 'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }

      # "the 1st and 2nd friday of every month" --> repeats monthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                 { |m1, m2| 'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/) { |m1, m2| 'repeats altmonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)           { |m1, m2| 'repeats threemonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }

      # "the 1st friday of every month" --> repeats monthly 1st friday
      # "the 1st friday and the 2nd tuesday of every month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                   { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/)   { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)             { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "the 1st friday saturday of every month" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/)                  { |m1, m2| 'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/)  { |m1, m2| 'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/)            { |m1, m2| 'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }

      # "repeats on the 1st and second friday of the month" --> repeats monthly 1st friday 2nd friday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                 { |m1, m2| 'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/) { |m1, m2| 'repeats altmonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)           { |m1, m2| 'repeats threemonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' ' }

      # "repeats on the 1st friday of the month --> repeats monthly 1st friday
      # "repeats on the 1st friday and second tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                   { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/)   { |m1| 'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)             { |m1| 'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "repeats on the 1st friday saturday of the month" --> repeats monthly 1st friday 1st saturday
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/)                  { |m1, m2| 'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/)  { |m1, m2| 'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }
      nsub!(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/)            { |m1, m2| 'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' ' }

      # "repeats each month" --> every month
      nsub!(/(repeats\s+)?(each|every)\s+\bmonth(ly)?/, 'every month ')
      nsub!(/all\s+months/, 'every month')

      # "repeats every other month" --> every other month
      nsub!(/(repeats\s+)?(each|every)\s+(other|2n?d?)\s+month(ly)?/, 'every other month ')
      nsub!(/(repeats\s+)?bimonthly/, 'every other month ')    # hyphens have already been replaced in spell check (bi-monthly)

      # "repeats every three months" --> every third month
      nsub!(/(repeats\s+)?(each|every)\s+3r?d?\s+month/, 'every third month ')
      nsub!(/(repeats\s+)?trimonthly/, 'every third month ')

      # All months
      nsub!(/(repeats\s+)?all\s+months/, 'every month ')
      nsub!(/(repeats\s+)?all\s+other\+months/, 'every other month ')

      # All month
      nsub!(/all\s+month/, 'this month ')
      nsub!(/all\s+next\s+month/, 'next month ')

      # "repeats 2nd mon" --> repeats monthly 2nd mon
      # "repeats 2nd mon, 3rd fri, and the last sunday" --> repeats monthly 2nd mon 3rd fri 5th sun
      nsub!(/repeats\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})/) { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' ' }

      # "starting at x, ending at y" --> from x to y
      nsub!(/(?:begin|start)(?:s|ing|ning)?\s+(?:at\s+)?#{TIME}\s+(?:and\s+)?end(?:s|ing)?\s+(?:at\s+)#{TIME}/, 'from \1 to \2')

      # "the x through the y"
      nsub!(/^(?:the\s+)?#{DATE_DD_WITH_SUFFIX}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_WITH_SUFFIX}$/, '\1 through \2 ')

      # "x week(s) away" --> x week(s) from now
      nsub!(/([0-9]+)\s+(day|week|month)s?\s+away/, '\1 \2s from now')

      # "x days from now" --> "x days from now"
      # "in 2 weeks|days|months" --> 2 days|weeks|months from now"
      nsub!(/\b(an?|[0-9]+)\s+(day|week|month)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
      nsub!(/in\s+(a|[0-9]+)\s+(week|day|month)s?/, '\1 \2 from now')

      # "x minutes|hours from now" --> "in x hours|minutes"
      # "in x hour(s)" --> 11/20/07 at 22:00
      # REDONE, no more calculations
      # "x minutes|hours from now" --> "x hours|minutes from now"
      # "in x hours|minutes --> x hours|minutes from now"
      nsub!(/\b(an?|[0-9]+)\s+(hour|minute)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
      nsub!(/in\s+(an?|[0-9]+)\s+(hour|minute)s?/, '\1 \2 from now')

      # Now only
      nsub!(/^(?:\s*)(?:right\s+)?now(?:\s*)$/, '0 minutes from now')

      # "a week/month from yesterday|tomorrow" --> 1 week from yesterday|tomorrow
      nsub!(/(?:(?:a|1)\s+)?(week|month)\s+from\s+(yesterday|tomorrow)/, '1 \1 from \2')

      # "a week/month from yesterday|tomorrow" --> 1 week from monday
      nsub!(/(?:(?:a|1)\s+)?(week|month)\s+from\s+#{DAY_OF_WEEK}/, '1 \1 from \2')

      # "every 2|3 days" --> every 2nd|3rd day
      nsub!(/every\s+(2|3)\s+days?/) { |m1| 'every ' + m1.to_i.ordinalize + ' day' }

      # "the following" --> following
      nsub!(/the\s+following/, 'following')

      # "friday the 12th to sunday the 14th" --> 12th through 14th
      nsub!(/#{DAY_OF_WEEK}\s+the\s+#{DATE_DD_WITH_SUFFIX}\s+(?:to|through|until)\s+#{DAY_OF_WEEK}\s+the\s+#{DATE_DD_WITH_SUFFIX}/, '\2 through \4')

      # "between 1 and 4" --> from 1 to 4
      nsub!(/between\s+#{TIME}\s+and\s+#{TIME}/, 'from \1 to \2')

      # "on the 3rd sat of this month" --> "3rd sat this month"
      # "on the 3rd sat and 5th tuesday of this month" --> "3rd sat this month 5th tuesday this month"
      # "on the 3rd sat and sunday of this month" --> "3rd sat this month 3rd sun this month"
      # "on the 2nd and 3rd sat of this month" --> "2nd sat this month 3rd sat this month"
      # This is going to be dicey, I'm going to remove 'the' from the following regexprsns:
      # The 'the' case will be handled AFTER wrapper substitution at end of this method
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:this|of)\s+month/)               { |m1, m2| m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 this month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:this|of)\s+month/)     { |m1, m2| m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:this|of)\s+month/) { |m1| m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK}/, '\1 this month') }

      # "on the 3rd sat of next month" --> "3rd sat next month"
      # "on the 3rd sat and 5th tuesday of next month" --> "3rd sat next month 5th tuesday next month"
      # "on the 3rd sat and sunday of next month" --> "3rd sat this month 3rd sun next month"
      # "on the 2nd and 3rd sat of next month" --> "2nd sat this month 3rd sat next month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?next\s+month/)                { |m1, m2| m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 next month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?next\s+month/)      { |m1, m2| m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' next month') }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?next\s+month/)  { |m1| m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK}/, '\1 next month') }

      # "on the 3rd sat of nov" --> "3rd sat nov"
      # "on the 3rd sat and 5th tuesday of nov" --> "3rd sat nov 5th tuesday nov            !!!!!!! walking a fine line here, 'nov 5th', but then again the entire nlp walks a pretty fine line
      # "on the 3rd sat and sunday of nov" --> "3rd sat nov 3rd sun nov"
      # "on the 2nd and 3rd sat of nov" --> "2nd sat nov 3rd sat nov"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)                { |m1, m2, m3| m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 ' + m3) }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)      { |m1, m2, m3| m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' ' + m3) }
      nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/)  { |m1, m2| m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK}/, '\1 ' + m2) }

      # "on the last day of nov" --> "last day nov"
      nsub!(/(?:\bon\s+)?(?:the\s+)?last\s+day\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR}/, 'last day \1')
      # "on the 1st|last day of this|the month" --> "1st|last day this month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?(?:this|the)?(?:\s*)month/, '\1 day this month')
      # "on the 1st|last day of next month" --> "1st|last day next month"
      nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?next\s+month/, '\1 day next month')

      # "every other weekend" --> every other sat sun
      nsub!(/every\s+other\s+weekend/, 'every other sat sun')

      # "this week on mon "--> this mon
      nsub!(/this\s+week\s+(?:on\s+)?#{DAY_OF_WEEK}/, 'this \1')
      # "mon of this week " --> this mon
      nsub!(/#{DAY_OF_WEEK}\s+(?:of\s+)?this\s+week/, 'this \1')

      # "next week on mon "--> next mon
      nsub!(/next\s+week\s+(?:on\s+)?#{DAY_OF_WEEK}/, 'next \1')
      # "mon of next week " --> next mon
      nsub!(/#{DAY_OF_WEEK}\s+(?:of\s+)?next\s+week/, 'next \1')

      # Ordinal this month:
      # this will slip by now
      # the 23rd of this|the month --> 8/23
      # this month on the 23rd --> 8/23
      # REDONE, no date calculations
      # the 23rd of this|the month --> 23rd this month
      # this month on the 23rd --> 23rd this month
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:of\s+)?(?:this|the)\s+month/, '\1 this month')
      nsub!(/this\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD}/, '\1 this month')

      # Ordinal next month:
      # this will slip by now
      # the 23rd of next month --> 9/23
      # next month on the 23rd --> 9/23
      # REDONE no date calculations
      # the 23rd of next month --> 23rd next month
      # next month on the 23rd --> 23rd next month
      nsub!(/(?:the\s+)?#{DATE_DD}\s+(?:of\s+)?(?:next|the\s+following)\s+month/, '\1 next month')
      nsub!(/(?:next|the\s+following)\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD}/, '\1 next month')

      # "for the next 3 days|weeks|months" --> for 3 days|weeks|months
      nsub!(/for\s+(?:the\s+)?(?:next|following)\s+(\d+)\s+(days|weeks|months)/, 'for \1 \2')

      # This monthname -> monthname
      nsub!(/this\s+#{MONTH_OF_YEAR}/, '\1')

      # Until monthname -> through monthname
      # through shouldn't be included here; through and until mean different things, need to fix wrapper terminology
      # "until june --> through june"
      nsub!(/(?:through|until)\s+(?:this\s+)?#{MONTH_OF_YEAR}\s+(?:$|\D)/, 'through \1')

      # the week of 1/2 -> week of 1/2
      nsub!(/(the\s+)?week\s+(of|starting)\s+(the\s+)?/, 'week of ')

      # the week ending 1/2 -> week through 1/2
      nsub!(/(the\s+)?week\s+(?:ending)\s+/, 'week through ')

      # clean up wrapper terminology
      # This should always be at end of pre-process
      nsub!(/(begin(s|ning)?|start(s|ing)?)(\s+(at|on))?/, 'start')
      nsub!(/(\bend(s|ing)?|through|until)(\s+(at|on))?/, 'through')
      nsub!(/start\s+(?:(?:this|in)\s+)?#{MONTH_OF_YEAR}/, 'start \1')

      # 'the' cases; what this is all about is if someone enters "first sunday of the month" they mean one date.  But if someone enters "first sunday of the month until december 2nd" they mean recurring
      # Do these actually do ANYTHING anymore?
      # "on the 3rd sat and sunday of the month" --> "repeats monthly 3rd sat 3rd sun"  OR  "3rd sat this month 3rd sun this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) { |m1, m2| 'repeats monthly ' + m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1') }
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:the)\s+month/) { |m1, m2| m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK}/, m1 + ' \1 this month') }
        end
      end

      # "on the 2nd and 3rd sat of this month" --> "repeats monthly 2nd sat 3rd sat"  OR  "2nd sat this month 3rd sat this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/) { |m1, m2| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2) }
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK}\s+(?:of\s+)?(?:the)\s+month/) { |m1, m2| m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month') }
        end
      end

      # "on the 3rd sat and 5th tuesday of this month" --> "repeats monthly 3rd sat 5th tue" OR "3rd sat this month 5th tuesday this month"
      if query_str =~ /(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/
        if query_str =~ /(start|through)\s+#{DATE_MM_SLASH_DD}/
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) { |m1| 'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') }
        else
          nsub!(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the)\s+month/) { |m1| m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK}/, '\1 this month') }
        end
      end

      nsub!(/from\s+now\s+(through|to|until)/, 'now through')
    end
  end
end
