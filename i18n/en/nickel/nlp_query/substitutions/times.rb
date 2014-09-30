{
  en: {
    nickel: {
      nlp_query: {
        substitutions: {
          times: [
            {
              from: [/\s+am\b/],
              to: 'am'
            },
            {
              from: [/\s+pm\b/],
              to: 'pm'
            }
          ]
        }
      }
    }
  }
}
