require "spec_helper"
require_relative "../../../lib/nickel/zdate"

module Nickel
  describe ZDate do
    describe "#get_next_date_from_date_of_month" do
      let(:d1) { ZDate.new("20090927") }

      it "is the next date with that day of the month" do
        expect(d1.get_next_date_from_date_of_month(28)).to eq ZDate.new("20090928")
        expect(d1.get_next_date_from_date_of_month(5)).to eq ZDate.new("20091005")
      end

      it "is nil when the current month has no such day of month" do
        expect(d1.get_next_date_from_date_of_month(31)).to be nil
      end
    end

    describe "#test_get_date_from_day_and_week_of_month" do
      let(:d1) { ZDate.new('20090927') }

      context "passed a negative number" do
        it "is the nth-last occurance of that day of the week that month" do
          expect(d1.get_date_from_day_and_week_of_month(ZDate::WED, -1)).to eq ZDate.new('20090930')
        end
      end

      context "passed a positive number" do
        it "is the nth occurance of that day of the week that month" do
          expect(d1.get_date_from_day_and_week_of_month(ZDate::WED, 5)).to eq ZDate.new('20090930')
        end

        it "flows on into the next month if there are not enough days that month" do
          expect(d1.get_date_from_day_and_week_of_month(ZDate::THU, 5)).to eq ZDate.new('20091001')
        end
      end
    end

    describe "#diff_in_days_to_this" do
      let(:d1) { ZDate.new("20090927") }
      let(:d2) { ZDate.new("20090930") }

      context "passed a weekend date" do
        it "is the number of days until that day of the week" do
          expect(d1.diff_in_days_to_this(ZDate::SUN)).to eq 0
          expect(d1.diff_in_days_to_this(ZDate::MON)).to eq 1
          expect(d1.diff_in_days_to_this(ZDate::TUE)).to eq 2
          expect(d1.diff_in_days_to_this(ZDate::WED)).to eq 3
          expect(d1.diff_in_days_to_this(ZDate::THU)).to eq 4
          expect(d1.diff_in_days_to_this(ZDate::FRI)).to eq 5
          expect(d1.diff_in_days_to_this(ZDate::SAT)).to eq 6
        end
      end

      context "passed a midweek date" do
        it "is the number of days until that day of the week" do
          expect(d2.diff_in_days_to_this(ZDate::WED)).to eq 0
          expect(d2.diff_in_days_to_this(ZDate::THU)).to eq 1
          expect(d2.diff_in_days_to_this(ZDate::FRI)).to eq 2
          expect(d2.diff_in_days_to_this(ZDate::SAT)).to eq 3
          expect(d2.diff_in_days_to_this(ZDate::SUN)).to eq 4
          expect(d2.diff_in_days_to_this(ZDate::MON)).to eq 5
          expect(d2.diff_in_days_to_this(ZDate::TUE)).to eq 6
        end
      end
    end

    describe "#to_date" do
      it "converts to a Date" do
        expect(ZDate.new('20090927').to_date).to eq Date.new(2009, 9, 27)
      end
    end

    describe "#==" do
      let(:d1) { ZDate.new('20090927') }

      it "is true when the other ZDate is for the very same day" do
        expect(d1).to eq ZDate.new('20090927')
      end

      it "is false when the other ZDate is for any other day" do
        expect(d1).to_not eq ZDate.new('20100927')
      end

      it "is true when the other object a Date for the same day" do
        expect(d1).to eq Date.new(2009, 9, 27)
      end

      it "is false when the other object is a Date for any other day" do
        expect(d1).to_not eq Date.new(2010, 9, 27)
      end
    end
  end
end
