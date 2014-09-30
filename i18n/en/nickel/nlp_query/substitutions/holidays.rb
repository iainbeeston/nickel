{
  en: {
    nickel: {
      nlp_query: {
        substitutions: {
          holidays: [
            {
              from: [/c?h[oa]nn?[aui][ck][ck]?[ua]h?/],
              to: 'hannukkah'
            },
            {
              from: [/x-?mas/],
              to: 'christmas'
            },
            {
              from: [/st\s+(patrick|patty|pat)s?(\s+day)?/],
              to: 'st patricks day'
            }
          ]
        }
      }
    }
  }
}
