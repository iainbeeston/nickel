module Nickel
  module Substitutor
    def self.extended(mod)
      mod.instance_variable_set(:@blocks, [])
    end

    def apply(nlp_query)
      @blocks.each do |blk|
        Evaluator.new(nlp_query).instance_eval(&blk)
      end
    end

    def substitutions(&block)
      @blocks << block
    end

    protected

    class Evaluator
      def initialize(nlp_query)
        @nlp_query = nlp_query
      end

      def sub(*args, &block)
        @nlp_query.nsub!(*args, &block)
      end
    end
  end
end
