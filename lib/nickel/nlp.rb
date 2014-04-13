require_relative 'zdate'
require_relative 'ztime'
require_relative 'nlp_query'
require_relative 'occurrence'
require_relative 'construct_finder'
require_relative 'construct_interpreter'

module Nickel
  class NLP
    attr_reader :query, :input_date, :input_time, :nlp_query
    attr_reader :construct_finder, :construct_interpreter
    attr_reader :occurrences, :message

    def initialize(query, date_time = Time.now)
      fail InvalidDateTimeError unless [DateTime, Time].include?(date_time.class)
      str_time = date_time.strftime('%Y%m%dT%H%M%S')
      validate_input query, str_time
      @query = query.dup
      @input_date = ZDate.new str_time[0..7]   # up to T, note format is already verified
      @input_time = ZTime.new str_time[9..14]  # after T
    end

    def parse
      @nlp_query = NLPQuery.new(@query).standardize   # standardizes the query
      @construct_finder = ConstructFinder.new(@nlp_query, @input_date, @input_time)
      @construct_finder.run

      extract_message
      correct_case

      @construct_interpreter = ConstructInterpreter.new(@construct_finder.constructs, @input_date)  # input_date only needed for wrappers
      @construct_interpreter.run

      @occurrences = @construct_interpreter.occurrences.each { |occ| occ.finalize(@input_date) }   # finds start and end dates
      # sorts occurrences by start date
      @occurrences.sort! do |x, y|
        if x.start_date > y.start_date
          1
        elsif x.start_date < y.start_date
          -1
        else
          0
        end
      end
      @occurrences
    end

    def inspect
      "message: \"#{message}\", occurrences: #{occurrences.inspect}"
    end

    private

    def extract_message
      # message could be all components put back together (which would be @nlp_query), so start with that
      message_array = @nlp_query.split
      constructs = @construct_finder.constructs

      # now iterate through constructs, blow away any words between positions comp_start and comp_end
      constructs.each do |c|
        # create a range between comp_start and comp_end, iterate through it and wipe out words between them
        (c.comp_start..c.comp_end).each { |x| message_array[x] = nil }
        # also wipe out words before comp start if it is something like in, at, on, or the
        if c.comp_start - 1 >= 0 && message_array[c.comp_start - 1] =~ /\b(from|in|at|on|the|are|is|for)\b/
          message_array[c.comp_start - 1] = nil
          if Regexp.last_match(1) == 'the' && c.comp_start - 2 >= 0 && message_array[c.comp_start - 2] =~ /\b(for|on)\b/    # for the next three days;  on the 27th;
            message_array[c.comp_start - 2] = nil
            if Regexp.last_match(1) == 'on' && c.comp_start - 3 >= 0 && message_array[c.comp_start - 3] =~ /\b(is|are)\b/         # is on the 28th;  are on the 21st and 22nd;
              message_array[c.comp_start - 3] = nil
            end
          elsif Regexp.last_match(1) == 'on' && c.comp_start - 2 >= 0 && message_array[c.comp_start - 2] =~ /\b(is|are)\b/      # is on tuesday; are on tuesday and wed;
            message_array[c.comp_start - 2] = nil
          end
        end
      end

      # reloop and wipe out words after end of constructs, if they are followed by another construct
      # note we already wiped out terms ahead of the constructs, so be sure to check for nil values, these indicate that a construct is followed by the nil
      constructs.each_with_index do |c, i|
        if message_array[c.comp_end + 1] && message_array[c.comp_end + 1] == 'and'    # do something tomorrow and on friday
          if message_array[c.comp_end + 2].nil? || (constructs[i + 1] && constructs[i + 1].comp_start == c.comp_end + 2)
            message_array[c.comp_end + 1] = nil
          elsif message_array[c.comp_end + 2] == 'also' && message_array[c.comp_end + 3].nil? || (constructs[i + 1] && constructs[i + 1].comp_start == c.comp_end + 3)    # do something tomorrow and also on friday
            message_array[c.comp_end + 1] = nil
            message_array[c.comp_end + 2] = nil
          end
        end
      end
      @message = message_array.compact.join(' ')   # remove nils and join the words with spaces
    end

    # returns any words in the query that appeared as input to their original case
    def correct_case
      orig = @query.split
      latest = @message.split
      orig.each_with_index do |original_word, j|
        if i = latest.index(original_word.downcase)
          latest[i] = original_word
        end
      end
      @message = latest.join(' ')
    end

    def validate_input(query, date_time)
      fail 'Empty NLP query' unless query.length > 0
      fail 'NLP says: date_time is not in the correct format' unless date_time =~ /^\d{8}T\d{6}$/
    end
  end

  class InvalidDateTimeError < StandardError
    def message
      'You must pass in a ruby DateTime or Time class object'
    end
  end
end
