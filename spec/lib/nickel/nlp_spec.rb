require 'spec_helper'
require_relative '../../../lib/nickel/nlp'

module Nickel
  describe NLP do
    describe '#new' do
      it 'raises an error if the current time argument is not a datetime or time object' do
        expect do
          NLP.new 'lunch 3 days from now', '2009-05-28'
        end.to raise_error('You must pass in an instance of DateTime, Time or ActiveSupport::TimeWithZone')
      end
    end
  end
end
