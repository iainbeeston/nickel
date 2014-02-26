require "spec_helper"
require_relative "../../../lib/nickel/nlp"

module Nickel
  describe NLP do
    describe "#new" do
      it "raises an error if the current time argument is not a datetime or time object" do
        expect{
          NLP.new "lunch 3 days from now", Date.new(2009,05,28)
        }.to raise_error("You must pass in a ruby DateTime or Time class object")
      end
    end
  end
end
