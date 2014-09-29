require 'spec_helper'
require 'nickel/construct'

module Nickel
  describe RecurrenceConstruct do
    describe '#get_interval', :deprecated do
      it 'is 1 when the recurrence is daily' do
        expect(RecurrenceConstruct.new(repeats: :daily).get_interval).to eq(1)
      end
    end

    describe '#interval' do
      it 'is 1 when the recurrence is daily' do
        expect(RecurrenceConstruct.new(repeats: :daily).interval).to eq(1)
      end

      it 'is 2 when the recurrence is every other day' do
        expect(RecurrenceConstruct.new(repeats: :altdaily).interval).to eq(2)
      end

      it 'is 3 when the recurrence is every three days' do
        expect(RecurrenceConstruct.new(repeats: :threedaily).interval).to eq(3)
      end

      it 'is 1 when the recurrence is weekly' do
        expect(RecurrenceConstruct.new(repeats: :weekly).interval).to eq(1)
      end

      it 'is 2 when the recurrence is every other week' do
        expect(RecurrenceConstruct.new(repeats: :altweekly).interval).to eq(2)
      end

      it 'is 3 when the recurrence is every three weeks' do
        expect(RecurrenceConstruct.new(repeats: :threeweekly).interval).to eq(3)
      end

      it 'is 1 when the recurrence is on a specific weekday each month' do
        expect(RecurrenceConstruct.new(repeats: :daymonthly).interval).to eq(1)
      end

      it 'is 2 when the recurrence is on a specific weekday every other month' do
        expect(RecurrenceConstruct.new(repeats: :altdaymonthly).interval).to eq(2)
      end

      it 'is 3 when the recurrence is on a specific weekday every three months' do
        expect(RecurrenceConstruct.new(repeats: :threedaymonthly).interval).to eq(3)
      end

      it 'is 1 when the recurrence is on a specific date each month' do
        expect(RecurrenceConstruct.new(repeats: :datemonthly).interval).to eq(1)
      end

      it 'is 2 when the recurrence is on a specific date every other month' do
        expect(RecurrenceConstruct.new(repeats: :altdatemonthly).interval).to eq(2)
      end

      it 'is 3 when the recurrence is on a specific date every three months' do
        expect(RecurrenceConstruct.new(repeats: :threedatemonthly).interval).to eq(3)
      end

      it 'raises a StandardError if the recurrence is not recognised' do
        expect{ RecurrenceConstruct.new(repeats: :fortnightly).interval }.to raise_error(StandardError)
      end
    end
  end
end
