require 'nickel/substitutor'

module Nickel
  module Substitutions
    class Formatting
      extend Substitutor

      substitutions do
        # unused punctuation
        sub(/\n/, '')
        sub(/,/, ' ')
        sub(/\./, '')
        sub(/;/, '')
        sub(/['`]/, '')
        sub(/\\/, '/')
        sub(/--?/, ' through ')

        # spell check
        sub(/tomm?orr?ow|romorrow/, 'tomorrow')
        sub(/weeknd/, 'weekend')
        sub(/weekends/, 'every sat sun')
        sub(/everyother/, 'every other')
        sub(/weak/, 'week')
        sub(/everyweek/, 'every week')
        sub(/everymonth/, 'every month')
        sub(/frist/, '1st')
        sub(/eveyr|evrey/, 'every')
        sub(/fridya|friady|fridy/, 'friday')
        sub(/thurdsday/, 'thursday')
        sub(/frouth/, 'fourth')
        sub(/\btill\b/, 'through')
        sub(/\bthru\b|\bthrouh\b|\bthough\b|\bthrew\b|\bthrow\b|\bthroug\b|\bthuogh\b/, 'through')
        sub(/weekdays|every\s+weekday/, 'every monday through friday')
        sub(/\bevery?day\b/, 'every day')
        sub(/eigth/, 'eighth')
        sub(/bi[-\s]monthly/, 'bimonthly')
        sub(/tri[-\s]monthly/, 'trimonthly')

        # unnecessary words
        sub(/coming/, '')
        sub(/o'?clock/, '')
        sub(/\btom\b/, 'tomorrow')
        sub(/\s*in\s+(the\s+)?(morning|am)/, ' am')
        sub(/\s*in\s+(the\s+)?(afternoon|pm|evenn?ing)/, ' pm')
        sub(/\s*at\s+night/, 'pm')
        sub(/(after\s*)?noon(ish)?/, '12:00pm')
        sub(/\bmi(dn|nd)ight\b/, '12:00am')
        sub(/final/, 'last')
        sub(/recur(s|r?ing)?/, 'repeats')
        sub(/\beach\b/, 'every')
        sub(/running\s+(until|through)/, 'through')
        sub(/runn?(s|ing)|go(ing|e?s)/, 'for')
        sub(/next\s+occ?urr?[ae]nce(\s+is)?/, 'start')
        sub(/next\s+date(\s+it)?(\s+occ?urr?s)?(\s+is)?/, 'start')
        sub(/forever/, 'repeats daily')
        sub(/\bany(?:\s*)day\b/, 'every day')
        sub(/^anytime$/, 'every day')  # user entered anytime by itself, not 'dayname anytime', caught next
        sub(/any(\s)?time|whenever/, 'all day')
        sub(/(?<!repeats )daily/, 'repeats daily')
        sub(/(?<!repeats )weekly/, 'repeats weekly')
        sub(/(?<!repeats )monthly/, 'repeats monthly')
      end
    end
  end
end
