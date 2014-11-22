module Nickel
  module Substitutor
    def apply(nlp_query)
      Evaluator.new(nlp_query).instance_eval(&@substitutions)
    end

    def substitutions(&block)
      @substitutions = block
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
