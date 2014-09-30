{
  en: {
    nickel: {
      nlp_query_constants: {
        date_dd: /\b((?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?)\b/,
        date_dd_nb_on_suffix: /\b(0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?\b/,
        date_dd_nb: /\b(?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)?\b/,
        date_dd_with_suffix: /\b((?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th))\b/,
        date_dd_without_suffix: /\b(0?[1-9]|[12][0-9]|3[01])\b/,
        date_dd_with_suffix_nb: /\b(?:0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)\b/,
        date_dd_without_suffix_nb: /\b(?:0?[1-9]|[12][0-9]|3[01])\b/,
        date_dd_with_suffix_nb_on_suffix: /\b(0?[1-9]|[12][0-9]|3[01])(?:st|nd|rd|th)\b/,
        date_mm_slash_dd: /\b(?:0?[1-9]|[1][0-2])\/(?:0?[1-9]|[12][0-9]|3[01])/,
        day_of_week: /\b(mon|tue|wed|thu|fri|sat|sun)\b/,
        day_of_week_nb: /\b(?:mon|tue|wed|thu|fri|sat|sun)\b/, # no backreference
        month_of_year: /\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b/,
        month_of_year_nb: /\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b/,
        time: /((?:(?:0?[1-9]|1[0-2])(?::[0-5][0-9])?(?:am|pm)?)|(?:[01]?[0-9]|2[0-3]:[0-5][0-9]))/,
        year: /((?:20)?0[789](?:\s|\n)|(?:20)[1-9][0-9])/,
        week_of_month: /(1st|2nd|3rd|4th|5th)/
      }
    }
  }
}
