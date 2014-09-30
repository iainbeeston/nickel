{
  en: {
    nickel: {
      nlp_query: {
        substitutions: {
          punctuation: [
            {
              from: [/\./, /;/, /['`]/],
              to: ''
            },
            {
              from: [/,\s*/],
              to: ' '
            },
            {
              from: [/\\/],
              to: '/'
            },
            {
              from: [/--?/],
              to: ' through '
            }
          ]
        }
      }
    }
  }
}
