{
  en: {
    nickel: {
      nlp_query: {
        substitutions: {
          unnecessary_words: [
            {
              from: [/coming/, /o'?clock/],
              to: ''
            },
            {
              from: [/\s*in\s+(the\s+)?(morning|am)/],
              to: ' am'
            },
            {
              from: [/\s*in\s+(the\s+)?(afternoon|pm|evening)/],
              to: ' pm'
            },
            {
              from: [/\s*at\s+night/],
              to: 'pm'
            },
            {
              from: [/(after\s*)?noon(ish)?/],
              to: '12:00pm'
            },
            {
              from: [/\bmidnight\b/],
              to: '12:00am'
            },
            {
              from: [/final/],
              to: 'last'
            },
            {
              from: [/recur(s|ring)?/],
              to: 'repeats'
            },
            {
              from: [/\beach\b/],
              to: 'every'
            },
            {
              from: [/running\s+(until|through)/],
              to: 'through'
            },
            {
              from: [/run(s|ning)/, /go(ing|es)/],
              to: 'for'
            },
            {
              from: [/next\s+occ?urr?[ae]nce(\s+is)?/, /next\s+date(\s+it)?(\s+occurs)?(\s+is)?/],
              to: 'start'
            },
            {
              from: [/forever/],
              to: 'repeats daily'
            },
            {
              from: [/\bany(?:\s*)day\b/, /^anytime$/, /\beveryday\b/],
              to: 'every day'
            },  # user entered anytime by itself, not 'dayname anytime', caught next
            {
              from: [/any(\s)?time|whenever/],
              to: 'all day'
            },
            {
              from: [/\beveryother\b/],
              to: 'every other'
            },
            {
              from: [/weekends/],
              to: 'every sat sun'
            },
            {
              from: [/\btill\b/],
              to: 'through'
            },
            {
              from: [/bi[-\s]monthly/],
              to: 'bimonthly'
            },
            {
              from: [/tri[-\s]monthly/],
              to: 'trimonthly'
            },
            {
              from: [/weekdays|every\s+weekday/],
              to: 'every monday through friday'
            }
          ]
        }
      }
    }
  }
}
