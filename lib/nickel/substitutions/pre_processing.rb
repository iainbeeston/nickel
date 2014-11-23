require 'nickel/substitutor'
require 'nickel/nlp_query_constants'

module Nickel
  module Substitutions
    class PreProcessing
      extend Substitutor
      include NLPQueryConstants

      substitutions do
        sub(/last\s+#{DAY_OF_WEEK.source}/, '5th \1') # last dayname  =>  5th dayname
        sub(/\ba\s+(week|month|day)/, '1 \1') # a month|week|day  =>  1 month|week|day
        sub(/^(through|until)/, 'today through') # ^through  =>  today through
        sub(/every\s*(night|morning)/, 'every day')
        sub(/tonight/, 'today')
        sub(/this(?:\s*)morning/, 'today')
        sub(/before\s+12pm/, '6am to 12pm') # arbitrary

        # Handle 'THE' Cases
        # Attempt to pick out where a user entered 'the' when they really mean 'every'.
        # For example,
        # The first of every month and the 22nd of THE month  =>  repeats monthly first xxxxxx repeats monthly 22nd xxxxxxx
        sub(/(?:the\s+)?#{DATE_DD_WITH_SUFFIX.source}\s+(?:of\s+)?(?:every|each)\s+month((?:.*)of\s+the\s+month(?:.*))/) do |m1, m2|
          ret_str = ' repeats monthly ' + m1
          ret_str << m2.gsub(/(?:and\s+)?(?:the\s+)?#{DATE_DD_WITH_SUFFIX.source}\s+of\s+the\s+month/, ' repeats monthly \1 ')
        end

        # Every first sunday of the month and the last tuesday  =>  repeats monthly first sunday xxxxxxxxx repeats monthly last tuesday xxxxxxx
        sub(/every\s+#{WEEK_OF_MONTH.source}\s+#{DAY_OF_WEEK.source}\s+of\s+(?:the\s+)?month((?:.*)and\s+(?:the\s+)?#{WEEK_OF_MONTH.source}\s+#{DAY_OF_WEEK.source}(?:.*))/) do |m1, m2, m3|
          ret_str = ' repeats monthly ' + m1 + ' ' + m2 + ' '
          ret_str << m3.gsub(/and\s+(?:the\s+)?#{WEEK_OF_MONTH.source}\s+#{DAY_OF_WEEK.source}(?:\s*)(?:of\s+)?(?:the\s+)?(?:month\s+)?/, ' repeats monthly \1 \2 ')
        end

        # The x through the y of oct z  =>  10/x/z through 10/y/z
        sub(/(?:the\s+)?#{DATE_DD.source}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD.source}\s(?:of\s+)#{MONTH_OF_YEAR.source}\s+(?:of\s+)?#{YEAR.source}/) do |m1, m2, m3, m4|
          (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + '/' + m4 + ' through ' +  (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2 + '/' + m4
        end

        # The x through the y of oct  =>  10/x through 10/y
        sub(/(?:the\s+)?#{DATE_DD.source}\s+(?:through|to|until)\s+(?:the\s+)#{DATE_DD.source}\s(?:of\s+)?#{MONTH_OF_YEAR.source}/) do |m1, m2, m3|
          (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m1 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m2
        end

        # January 1 - February 15
        sub(/#{MONTH_OF_YEAR.source}\s+#{DATE_DD_NB_ON_SUFFIX.source}\s+(?:through|to|until)\s+#{MONTH_OF_YEAR.source}\s#{DATE_DD_NB_ON_SUFFIX.source}/) do |m1, m2, m3, m4|
          (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2.gsub(/(st|nd|rd|th)/, '') + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4.gsub(/(st|nd|rd|th)/, '')
        end

        # Tuesday, january 1 - friday, february 15, 2013
        sub(/(?:#{DAY_OF_WEEK.source})?(?:[\s,]+)#{MONTH_OF_YEAR.source}(?:[\s,]+)#{DATE_DD.source}\s+(?:through|to|until)\s+(?:#{DAY_OF_WEEK.source})?(?:[\s,]+)#{MONTH_OF_YEAR.source}(?:[\s,]+)#{DATE_DD.source}(?:[\s,]+)#{YEAR.source}/) do |m1, m2, m3, m4, m5, m6, m7|
          if m7.nil?
            (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3.gsub(/(st|nd|rd|th)/, '') + ' through ' + (ZDate.months_of_year.index(m5) + 1).to_s + '/' + m6
          else
            (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3.gsub(/(st|nd|rd|th)/, '') + '/' + m7 + ' through ' + (ZDate.months_of_year.index(m5) + 1).to_s + '/' + m6.gsub(/(st|nd|rd|th)/, '') + '/' + m7
          end
        end

        # Tuesday, january 1 2013 - friday, february 15, 2013
        sub(/(?:#{DAY_OF_WEEK.source})?(?:[\s,]+)#{MONTH_OF_YEAR.source}(?:[\s,]+)#{DATE_DD.source}\s+#{YEAR.source}\s+(?:through|to|until)\s+(?:#{DAY_OF_WEEK.source})?(?:[\s,]+)#{MONTH_OF_YEAR.source}(?:[\s,]+)#{DATE_DD.source}(?:[\s,]+)#{YEAR.source}/) do |m1, m2, m3, m4, m5, m6, m7, m8|
          (ZDate.months_of_year.index(m2) + 1).to_s + '/' + m3 + '/' + m4 + ' through ' + (ZDate.months_of_year.index(m6) + 1).to_s + '/' + m7 + '/' + m8
        end

        # Monthname x through y
        sub(/#{MONTH_OF_YEAR.source}\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX.source}\s+(?:of\s+)?(?:#{YEAR.source}\s+)?(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_NB_ON_SUFFIX.source}(?:\s+of)?(?:\s+#{YEAR.source})?/) do |m1, m2, m3, m4, m5|
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
        sub(/#{MONTH_OF_YEAR.source}\s+#{DATE_DD_NB_ON_SUFFIX.source}\s+(?:to|through|until)\s+#{MONTH_OF_YEAR.source}\s+#{DATE_DD_NB_ON_SUFFIX.source}\s+(?:of\s+)?(?:#{YEAR.source})?/) do |m1, m2, m3, m4, m5|
          if m5
            (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + '/' + m5 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + '/' + m5 + ' '
          else
            (ZDate.months_of_year.index(m1) + 1).to_s + '/' + m2 + ' through ' + (ZDate.months_of_year.index(m3) + 1).to_s + '/' + m4 + ' '
          end
        end

        # Mnday the 23rd, tuesday the 24th and wed the 25th of oct  =>  11/23 11/24 11/25
        sub(/((?:#{DAY_OF_WEEK_NB.source}\s+the\s+#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?){1,31})of\s+#{MONTH_OF_YEAR.source}\s*(#{YEAR.source})?/) do |m1, m2, m3|
          month_str = (ZDate.months_of_year.index(m2) + 1).to_s
          if m3
            m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK.source}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/, month_str + '/\1/' + m3)
          else
            m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK.source}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/, month_str + '/\1')
          end
        end

        # the 23rd and 24th of october                    =>  11/23 11/24
        # the 23rd, 24th, and 25th of october             =>  11/23 11/24 11/25
        # the 23rd, 24th, and 25th of october 2010        =>  11/23/2010 11/24/2010 11/25/2010
        # monday and tuesday, the 23rd and 24th of july   =>  7/23 7/24
        sub(/(?:(?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:day\s+)?(?:in\s+)?(?:of\s+)#{MONTH_OF_YEAR.source}\s*(#{YEAR.source})?/) do |m1, m2, m3|
          month_str = (ZDate.months_of_year.index(m2) + 1).to_s
          if m3
            m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK.source}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/, month_str + '/\1/' + m3)
          else
            m1.gsub(/\b(and|the)\b|#{DAY_OF_WEEK.source}/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/, month_str + '/\1')
          end
        end

        # Match date with year first.
        # Don't allow mixing of suffixes, e.g. "dec 3rd 2008 at 4 and dec 5 2008 9 to 5"
        # Dec 2nd, 3rd, and 5th 2008  => 12/2/2008 12/2/2008 12/5/2008
        # Mon nov 23rd 08
        # Dec 2, 3, 5, 2008  =>  12/2/2008 12/3/2008 12/5/2008
        sub(/(?:(?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR.source}\s+((?:(?:the\s+)?#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?){1,31})#{YEAR.source}/) do |m1, m2, m3|
          month_str = (ZDate.months_of_year.index(m1) + 1).to_s
          m2.gsub(/\b(and|the)\b/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/, month_str + '/\1/' + m3)
        end

        sub(/(?:(?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR.source}\s+((?:(?:the\s+)?#{DATE_DD_WITHOUT_SUFFIX_NB.source}\s+(?:and\s+)?){1,31})#{YEAR.source}/) do |m1, m2, m3|
          month_str = (ZDate.months_of_year.index(m1) + 1).to_s
          m2.gsub(/\b(and|the)\b/, '').gsub(/#{DATE_DD_WITHOUT_SUFFIX.source}/, month_str + '/\1/' + m3)
        end

        # Dec 2nd, 3rd, and 4th  =>  12/2, 12/3, 12/4
        # Note: dec 5 9 to 5 will give an error, need to find these and convert to dec 5 from 9 to 5; also dec 3,4, 9 to|through 5 --> dec 3, 4 from 9 through 5
        sub(/(?:(?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR.source}\s+(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1, m2|
          month_str = (ZDate.months_of_year.index(m1) + 1).to_s
          m2.gsub(/(and|the)/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/) { month_str + '/' + Regexp.last_match(1) }  # last match is from the nested match!
        end

        # Apr 29, 5 - 8pm
        sub(/#{MONTH_OF_YEAR.source}(?:\s)+#{DATE_DD_WITHOUT_SUFFIX.source}(?:,)?(?:\s)+(#{TIME.source} through #{TIME.source})/) do |m1, m2, m3|
          month_str = (ZDate.months_of_year.index(m1) + 1).to_s
          "#{month_str}/#{m2} #{m3}"
        end

        # jan 4 2-3 has to be modified, but
        # jan 24 through jan 26 cannot!
        # not real sure what this one is doing
        # "dec 2, 3, and 4" --> 12/2, 12/3, 12/4
        # "mon, tue, wed, dec 2, 3, and 4" --> 12/2, 12/3, 12/4
        sub(/(#{MONTH_OF_YEAR_NB.source}\s+(?:the\s+)?(?:(?:#{DATE_DD_WITHOUT_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:to|through|until)\s+#{DATE_DD_WITHOUT_SUFFIX_NB.source})/) do |m1|
          m1.gsub(/#{DATE_DD_WITHOUT_SUFFIX.source}\s+(to|through|until)/, 'from \1 through ')
        end
        sub(/(?:(?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})?#{MONTH_OF_YEAR.source}\s+(?:the\s+)?((?:#{DATE_DD_WITHOUT_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1, m2|
          month_str = (ZDate.months_of_year.index(m1) + 1).to_s
          m2.gsub(/(and|the)/, '').gsub(/#{DATE_DD_NB_ON_SUFFIX.source}/) { month_str + '/' + Regexp.last_match(1) }  # last match is from nested match
        end

        # "monday 12/6" --> 12/6
        sub(/#{DAY_OF_WEEK_NB.source}\s+(#{DATE_MM_SLASH_DD.source})/, '\1')

        # "next friday to|until|through the following tuesday" --> 10/12 through 10/16
        # "next friday through sunday" --> 10/12 through 10/14
        # "next friday and the following sunday" --> 11/16 11/18
        # we are not going to do date calculations here anymore, so instead:
        # next friday to|until|through the following tuesday" --> next friday through tuesday
        # next friday and the following sunday --> next friday and sunday
        sub(/next\s+#{DAY_OF_WEEK.source}\s+(to|until|through|and)\s+(?:the\s+)?(?:following|next)?(?:\s*)#{DAY_OF_WEEK.source}/) do |m1, m2, m3|
          connector = (m2 =~ /and/ ? ' ' : ' through ')
          'next ' + m1 + connector + m3
        end

        # "this friday to|until|through the following tuesday" --> 10/5 through 10/9
        # "this friday through following sunday" --> 10/5 through 10/7
        # "this friday and the following monday" --> 11/9 11/12
        # No longer performing date calculation
        # this friday and the following monday --> fri mon
        # this friday through the following tuesday --> fri through tues
        sub(/(?:this\s+)?#{DAY_OF_WEEK.source}\s+(to|until|through|and)\s+(?:the\s+)?(?:this|following)(?:\s*)#{DAY_OF_WEEK.source}/) do |m1, m2, m3|
          connector = (m2 =~ /and/ ? ' ' : ' through ')
          m1 + connector + m3
        end

        # "the wed after next" --> 2 wed from today
        sub(/(?:the\s+)?#{DAY_OF_WEEK.source}\s+(?:after|following)\s+(?:the\s+)?next/, '2 \1 from today')

        # "mon and tue" --> mon tue
        sub(/(#{DAY_OF_WEEK.source}\s+and\s+#{DAY_OF_WEEK.source})(?:\s+and)?/, '\2 \3')

        # "mon wed every week" --> every mon wed
        sub(/((#{DAY_OF_WEEK.source}(?:\s*)){1,7})(?:of\s+)?(?:every|each)(\s+other)?\s+week/, 'every \4 \1')

        # "every week on mon tue fri" --> every mon tue fri
        sub(/(?:repeats\s+)?every\s+(?:(other|3rd|2nd)\s+)?weeks?\s+(?:\bon\s+)?((?:#{DAY_OF_WEEK_NB.source}\s+){1,7})/, 'every \1 \2')

        # "every mon and every tue and.... " --> every mon tue ...
        sub(/every\s+#{DAY_OF_WEEK.source}\s+(?:and\s+)?every\s+#{DAY_OF_WEEK.source}(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK.source})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK.source})?(?:\s+(?:and\s+)?every\s+#{DAY_OF_WEEK.source})?/, 'every \1 \2 \3 \4 \5')

        # monday, wednesday, and friday next week at 8
        sub(/((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){1,7})(?:of\s+)?(this|next)\s+week/, '\2 \1')

        # "every day this|next week"  --> returns monday through friday of the closest week, kinda stupid
        # doesn't do that anymore, no date calculations allowed here, instead just formats it nicely for construct finders --> every day this|next week
        sub(/every\s+day\s+(?:of\s+)?(this|the|next)\s+week\b./) do |m1|
          m1 == 'next' ? 'every day next week' : 'every day this week'
        end

        # "every day for the next week" --> "every day this week"
        sub(/every\s+day\s+for\s+(the\s+)?(next|this)\s+week/, 'every day this week')

        # "this weekend" --> sat sun
        sub(/(every\s+day\s+|both\s+days\s+)?this\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/, 'sat sun')

        # "this weekend including mon" --> sat sun mon
        sub(/sat\s+sun\s+(and|includ(es?|ing))\s+mon/, 'sat sun mon')
        sub(/sat\s+sun\s+(and|includ(es?|ing))\s+fri/, 'fri sat sun')

        # Note: next weekend including monday will now fail.  Need to make constructors find "next sat sun mon"
        # "next weekend" --> next weekend
        sub(/(every\s+day\s+|both\s+days\s+)?next\s+weekend(\s+on)?(\s+both\s+days|\s+every\s+day|\s+sat\s+sun)?/, 'next weekend')

        # "next weekend including mon" --> next sat sun mon
        sub(/next\s+weekend\s+(and|includ(es?|ing))\s+mon/, 'next sat sun mon')
        sub(/next\s+weekend\s+(and|includ(es?|ing))\s+fri/, 'next fri sat sun')

        # "every weekend" --> every sat sun
        sub(/every\s+weekend(?:\s+(?:and|includ(?:es?|ing))\s+(mon|fri))?/, 'every sat sun' + ' \1') # regarding "every sat sun fri", order should not matter after "every" keyword

        # "weekend" --> sat sun     !!! catch all
        sub(/weekend/, 'sat sun')

        # "mon through wed" -- >  mon tue wed
        # CATCH ALL FOR SPANS, TRY NOT TO USE THIS
        sub(/#{DAY_OF_WEEK.source}\s+(?:through|to|until)\s+#{DAY_OF_WEEK.source}/) do |m1, m2|
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
        sub(/\b(repeat(?:s|ing)?|every|each)\s+da(ily|y)\b/, 'repeats daily')

        # "every other week starting this|next fri" --> every other friday starting this friday
        sub(/every\s+(3rd|other)\s+week\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+#{DAY_OF_WEEK.source}/, 'every \1 \3 start \2 \3')

        # "every other|3rd friday starting this|next week" --> every other|3rd friday starting this|next friday
        sub(/every\s+(3rd|other)\s+#{DAY_OF_WEEK.source}\s+(?:start(?:s|ing)?|begin(?:s|ning)?)\s+(this|next)\s+week/, 'every \1 \2 start \3 \2')

        # "repeats monthly on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
        # "repeats every other month on the 1st and 2nd friday" --> repeats monthly 1st friday 2nd friday
        # "repeats every three months on the 1st and 2nd friday" --> repeats threemonthly 1st friday 2nd friday
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+months?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}/) do |m1, m2|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end

        # "repeats monthly on the 1st friday" --> repeats monthly 1st friday
        # "repeats monthly on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
        # "repeats every other month on the 1st friday, second tuesday, and third friday" --> repeats monthly 1st friday 2nd tuesday 3rd friday
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "repeats monthly on the 1st friday saturday" --> repeats monthly 1st friday 1st saturday
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:ly|s)?\s+(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})/) do |m1, m2|
          'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end

        # "21st of each month" --> repeats monthly 21st
        # "on the 21st, 22nd and 25th of each month" --> repeats monthly 21st 22nd 25th
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+\bmonths?/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+(?:other|2n?d?)\s+months?/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,31})(?:days?\s+)?(?:of\s+)?(?:each|all|every)\s+3r?d?\s+months?/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "repeats each month on the 22nd" --> repeats monthly 22nd
        # "repeats monthly on the 22nd 23rd and 24th" --> repeats monthly 22nd 23rd 24th
        # This can ONLY handle multi-day recurrence WITHOUT independent times for each, i.e. "repeats monthly on the 22nd at noon and 24th from 1 to 9"  won't work; that's going to be a tricky one.
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        # sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonth(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats monthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?\bmonthly\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        # sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?(?:other|2n?d?)\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats altmonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}
        sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)?\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        # sub(/(?:repeats\s+)?(?:(?:each|every|all)\s+)?3r?d?\s+month(?:s|ly)\s+(?:on\s+)?(?:the\s+)?((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/)  { |m1| "repeats threemonthly " + m1.gsub(/\b(and|the)\b/,'') + " "}

        # "on day 4 of every month" --> repeats monthly 4
        # "on days 4 9 and 14 of every month" --> repeats monthly 4 9 14
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+\bmonths?/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+(?:other|2n?d?)\s+months?/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:day|date)s?\s+((?:#{DATE_DD_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)(every|all|each)\s+3r?d?\s+months?/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "every 22nd of the month" --> repeats monthly 22
        # "every 22nd 23rd and 25th of the month" --> repeats monthly 22 23 25
        sub(/(?:repeats\s+)?(?:every|each)\s+((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:every|each)\s+other\s+((?:#{DATE_DD_WITH_SUFFIX_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:day\s+)?(?:of\s+)?(?:the\s+)?\bmonth/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "every 1st and 2nd fri of the month" --> repeats monthly 1st fri 2nd fri
        sub(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1, m2|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1, m2|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end

        # "every 1st friday of the month" --> repeats monthly 1st friday
        # "every 1st friday and 2nd tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
        sub(/(?:repeats\s+)?(?:each|every|all)\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:each|every|all)\s+other\s+((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "every 1st fri sat of the month" --> repeats monthly 1st fri 1st sat
        sub(/(?:repeats\s+)?(?:each|every|all)\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1, m2|
          'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:each|every|all)\s+other\s+(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:the\s+)?(?:(?:each|every|all)\s+)?\bmonths?/) do |m1, m2|
          'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end

        # "the 1st and 2nd friday of every month" --> repeats monthly 1st friday 2nd friday
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/) do |m1, m2|
          'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/) do |m1, m2|
          'repeats altmonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/) do |m1, m2|
          'repeats threemonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end

        # "the 1st friday of every month" --> repeats monthly 1st friday
        # "the 1st friday and the 2nd tuesday of every month" --> repeats monthly 1st friday 2nd tuesday
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "the 1st friday saturday of every month" --> repeats monthly 1st friday 1st saturday
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)\bmonths?/) do |m1, m2|
          'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)(?:other|2n?d?)\s+months?/) do |m1, m2|
          'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)?(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all)\s+)3r?d?\s+months?/) do |m1, m2|
          'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end

        # "repeats on the 1st and second friday of the month" --> repeats monthly 1st friday 2nd friday
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/) do |m1, m2|
          'repeats monthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/) do |m1, m2|
          'repeats altmonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,5})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/) do |m1, m2|
          'repeats threemonthly ' +  m1.gsub(/\b(and|the)\b/, '').split.join(' ' + m2 + ' ') + ' ' + m2 + ' '
        end

        # "repeats on the 1st friday of the month --> repeats monthly 1st friday
        # "repeats on the 1st friday and second tuesday of the month" --> repeats monthly 1st friday 2nd tuesday
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/) do |m1|
          'repeats altmonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/) do |m1|
          'repeats threemonthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "repeats on the 1st friday saturday of the month" --> repeats monthly 1st friday 1st saturday
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?\bmonths?/) do |m1, m2|
          'repeats monthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?(?:other|2n?d?)\s+months?/) do |m1, m2|
          'repeats altmonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end
        sub(/(?:repeats\s+)(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+){2,7})(?:of\s+)?(?:(?:every|each|all|the)\s+)?3r?d?\s+months?/) do |m1, m2|
          'repeats threemonthly ' + m1 + ' ' + m2.split.join(' ' + m1 + ' ') + ' '
        end

        # "repeats each month" --> every month
        sub(/(repeats\s+)?(each|every)\s+\bmonth(ly)?/, 'every month ')
        sub(/all\s+months/, 'every month')

        # "repeats every other month" --> every other month
        sub(/(repeats\s+)?(each|every)\s+(other|2n?d?)\s+month(ly)?/, 'every other month ')
        sub(/(repeats\s+)?bimonthly/, 'every other month ') # hyphens have already been replaced in spell check (bi-monthly)

        # "repeats every three months" --> every third month
        sub(/(repeats\s+)?(each|every)\s+3r?d?\s+month/, 'every third month ')
        sub(/(repeats\s+)?trimonthly/, 'every third month ')

        # All months
        sub(/(repeats\s+)?all\s+months/, 'every month ')
        sub(/(repeats\s+)?all\s+other\+months/, 'every other month ')

        # All month
        sub(/all\s+month/, 'this month ')
        sub(/all\s+next\s+month/, 'next month ')

        # "repeats 2nd mon" --> repeats monthly 2nd mon
        # "repeats 2nd mon, 3rd fri, and the last sunday" --> repeats monthly 2nd mon 3rd fri 5th sun
        sub(/repeats\s+(?:\bon\s+)?(?:the\s+)?((?:(?:1|2|3|4|5)(?:st|nd|rd|th)?\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})/) do |m1|
          'repeats monthly ' + m1.gsub(/\b(and|the)\b/, '') + ' '
        end

        # "starting at x, ending at y" --> from x to y
        sub(/(?:begin|start)(?:s|ing|ning)?\s+(?:at\s+)?#{TIME.source}\s+(?:and\s+)?end(?:s|ing)?\s+(?:at\s+)#{TIME.source}/, 'from \1 to \2')

        # "the x through the y"
        sub(/^(?:the\s+)?#{DATE_DD_WITH_SUFFIX.source}\s+(?:through|to|until)\s+(?:the\s+)?#{DATE_DD_WITH_SUFFIX.source}$/, '\1 through \2 ')

        # "x week(s) away" --> x week(s) from now
        sub(/([0-9]+)\s+(day|week|month)s?\s+away/, '\1 \2s from now')

        # "x days from now" --> "x days from now"
        # "in 2 weeks|days|months" --> 2 days|weeks|months from now"
        sub(/\b(an?|[0-9]+)\s+(day|week|month)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
        sub(/in\s+(a|[0-9]+)\s+(week|day|month)s?/, '\1 \2 from now')

        # "x minutes|hours from now" --> "in x hours|minutes"
        # "in x hour(s)" --> 11/20/07 at 22:00
        # REDONE, no more calculations
        # "x minutes|hours from now" --> "x hours|minutes from now"
        # "in x hours|minutes --> x hours|minutes from now"
        sub(/\b(an?|[0-9]+)\s+(hour|minute)s?\s+(?:from\s+now|away)/, '\1 \2 from now')
        sub(/in\s+(an?|[0-9]+)\s+(hour|minute)s?/, '\1 \2 from now')

        # Now only
        sub(/^(?:\s*)(?:right\s+)?now(?:\s*)$/, '0 minutes from now')

        # "a week/month from yesterday|tomorrow" --> 1 week from yesterday|tomorrow
        sub(/(?:(?:a|1)\s+)?(week|month)\s+from\s+(yesterday|tomorrow)/, '1 \1 from \2')

        # "a week/month from yesterday|tomorrow" --> 1 week from monday
        sub(/(?:(?:a|1)\s+)?(week|month)\s+from\s+#{DAY_OF_WEEK.source}/, '1 \1 from \2')

        # "the following" --> following
        sub(/the\s+following/, 'following')

        # "friday the 12th to sunday the 14th" --> 12th through 14th
        sub(/#{DAY_OF_WEEK.source}\s+the\s+#{DATE_DD_WITH_SUFFIX.source}\s+(?:to|through|until)\s+#{DAY_OF_WEEK.source}\s+the\s+#{DATE_DD_WITH_SUFFIX.source}/, '\2 through \4')

        # "between 1 and 4" --> from 1 to 4
        sub(/between\s+#{TIME.source}\s+and\s+#{TIME.source}/, 'from \1 to \2')

        # "on the 3rd sat of this month" --> "3rd sat this month"
        # "on the 3rd sat and 5th tuesday of this month" --> "3rd sat this month 5th tuesday this month"
        # "on the 3rd sat and sunday of this month" --> "3rd sat this month 3rd sun this month"
        # "on the 2nd and 3rd sat of this month" --> "2nd sat this month 3rd sat this month"
        # This is going to be dicey, I'm going to remove 'the' from the following regexprsns:
        # The 'the' case will be handled AFTER wrapper substitution at end of this method
        sub(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:this|of)\s+month/) do |m1, m2|
          m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK.source}/, m1 + ' \1 this month')
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:this|of)\s+month/) do |m1, m2|
          m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' this month')
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:this|of)\s+month/) do |m1|
          m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK.source}/, '\1 this month')
        end

        # "on the 3rd sat of next month" --> "3rd sat next month"
        # "on the 3rd sat and 5th tuesday of next month" --> "3rd sat next month 5th tuesday next month"
        # "on the 3rd sat and sunday of next month" --> "3rd sat this month 3rd sun next month"
        # "on the 2nd and 3rd sat of next month" --> "2nd sat this month 3rd sat next month"
        sub(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?next\s+month/) do |m1, m2|
          m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK.source}/, m1 + ' \1 next month')
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?next\s+month/) do |m1, m2|
          m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' next month')
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?next\s+month/) do |m1|
          m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK.source}/, '\1 next month')
        end

        # "on the 3rd sat of nov" --> "3rd sat nov"
        # "on the 3rd sat and 5th tuesday of nov" --> "3rd sat nov 5th tuesday nov            !!!!!!! walking a fine line here, 'nov 5th', but then again the entire nlp walks a pretty fine line
        # "on the 3rd sat and sunday of nov" --> "3rd sat nov 3rd sun nov"
        # "on the 2nd and 3rd sat of nov" --> "2nd sat nov 3rd sat nov"
        sub(/(?:\bon\s+)?(?:the\s+)?(1st|2nd|3rd|4th|5th)\s+((?:#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?){2,7})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR.source}/) do |m1, m2, m3|
          m2.gsub(/\band\b/, '').gsub(/#{DAY_OF_WEEK.source}/, m1 + ' \1 ' + m3)
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+(?:and\s+)?(?:the\s+)?){2,7})#{DAY_OF_WEEK.source}\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR.source}/) do |m1, m2, m3|
          m1.gsub(/\b(and|the)\b/, '').gsub(/(1st|2nd|3rd|4th|5th)/, '\1 ' + m2 + ' ' + m3)
        end
        sub(/(?:\bon\s+)?(?:the\s+)?((?:(?:1st|2nd|3rd|4th|5th)\s+#{DAY_OF_WEEK_NB.source}\s+(?:and\s+)?(?:the\s+)?){1,10})(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR.source}/) do |m1, m2|
          m1.gsub(/\b(and|the)\b/, '').gsub(/#{DAY_OF_WEEK.source}/, '\1 ' + m2)
        end

        # "on the last day of nov" --> "last day nov"
        sub(/(?:\bon\s+)?(?:the\s+)?last\s+day\s+(?:of\s+)?(?:in\s+)?#{MONTH_OF_YEAR.source}/, 'last day \1')
        # "on the 1st|last day of this|the month" --> "1st|last day this month"
        sub(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?(?:this|the)?(?:\s*)month/, '\1 day this month')
        # "on the 1st|last day of next month" --> "1st|last day next month"
        sub(/(?:\bon\s+)?(?:the\s+)?(1st|last)\s+day\s+(?:of\s+)?next\s+month/, '\1 day next month')

        # "every other weekend" --> every other sat sun
        sub(/every\s+other\s+weekend/, 'every other sat sun')

        # "this week on mon "--> this mon
        sub(/this\s+week\s+(?:on\s+)?#{DAY_OF_WEEK.source}/, 'this \1')
        # "mon of this week " --> this mon
        sub(/#{DAY_OF_WEEK.source}\s+(?:of\s+)?this\s+week/, 'this \1')

        # "next week on mon "--> next mon
        sub(/next\s+week\s+(?:on\s+)?#{DAY_OF_WEEK.source}/, 'next \1')
        # "mon of next week " --> next mon
        sub(/#{DAY_OF_WEEK.source}\s+(?:of\s+)?next\s+week/, 'next \1')

        # Ordinal this month:
        # this will slip by now
        # the 23rd of this|the month --> 8/23
        # this month on the 23rd --> 8/23
        # REDONE, no date calculations
        # the 23rd of this|the month --> 23rd this month
        # this month on the 23rd --> 23rd this month
        sub(/(?:the\s+)?#{DATE_DD.source}\s+(?:of\s+)?(?:this|the)\s+month/, '\1 this month')
        sub(/this\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD.source}/, '\1 this month')

        # Ordinal next month:
        # this will slip by now
        # the 23rd of next month --> 9/23
        # next month on the 23rd --> 9/23
        # REDONE no date calculations
        # the 23rd of next month --> 23rd next month
        # next month on the 23rd --> 23rd next month
        sub(/(?:the\s+)?#{DATE_DD.source}\s+(?:of\s+)?(?:next|the\s+following)\s+month/, '\1 next month')
        sub(/(?:next|the\s+following)\s+month\s+(?:(?:on|the)\s+)?(?:(?:on|the)\s+)?#{DATE_DD.source}/, '\1 next month')

        # "for the next 3 days|weeks|months" --> for 3 days|weeks|months
        sub(/for\s+(?:the\s+)?(?:next|following)\s+(\d+)\s+(days|weeks|months)/, 'for \1 \2')

        # This monthname -> monthname
        sub(/this\s+#{MONTH_OF_YEAR.source}/, '\1')

        # Until monthname -> through monthname
        # through shouldn't be included here; through and until mean different things, need to fix wrapper terminology
        # "until june --> through june"
        sub(/(?:through|until)\s+(?:this\s+)?#{MONTH_OF_YEAR.source}\s+(?:$|\D)/, 'through \1')

        # the week of 1/2 -> week of 1/2
        sub(/(the\s+)?week\s+(of|starting)\s+(the\s+)?/, 'week of ')

        # the week ending 1/2 -> week through 1/2
        sub(/(the\s+)?week\s+(?:ending)\s+/, 'week through ')

        # clean up wrapper terminology
        # This should always be at end of pre-process
        sub(/(begin(s|ning)?|start(s|ing)?)(\s+(at|on))?/, 'start')
        sub(/(\bend(s|ing)?|through|until)(\s+(at|on))?/, 'through')
        sub(/start\s+(?:(?:this|in)\s+)?#{MONTH_OF_YEAR.source}/, 'start \1')

        sub(/from\s+now\s+(through|to|until)/, 'now through')
      end
    end
  end
end
