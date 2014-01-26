require "spec_helper.rb"
require_relative "../../lib/nickel"

describe "Nickel#parse" do
  context "passed a single date" do
    let(:n) { Nickel.parse "oct 15 09" }

    it "has an empty message" do
      expect(n.message).to be_empty
    end

    it "has a start date" do
      expect(n.occurrences.size).to eq 1
      expect(n.occurrences.first.start_date.date).to eq "20091015"
    end
  end

  context "passed a daily occurrence" do
    let(:n) { Nickel.parse "wake up everyday at 11am" }
    let(:occurs) { n.occurrences.first }

    it "has a message" do
      expect(n.message).to eq "wake up"
    end

    it "is daily" do
      expect(occurs.type).to eq :daily
    end

    it "has a start time" do
      expect(occurs.start_time.time).to eq "110000"
    end
  end

  context "passed a weekly occurrence" do
    let(:n) { Nickel.parse "guitar lessons every tuesday at 5pm" }
    let(:occurs) { n.occurrences.first }

    it "has a message" do
      expect(n.message).to eq "guitar lessons"
    end

    it "is weekly" do
      expect(occurs.type).to eq :weekly
    end

    it "occurs on tuesdays" do
      expect(occurs.day_of_week).to eq 1
    end

    it "occurs once per week" do
      expect(occurs.interval).to eq 1
    end

    it "starts at 5pm" do
      expect(occurs.start_time.time).to eq "170000"
    end

    it "has a start date" do
      expect(occurs.start_date).to_not be_nil
    end

    it "does not have an end date" do
      expect(occurs.end_date).to be_nil
    end
  end

  context "passed a day monthly occurrence" do
    let(:n) { Nickel.parse "drink specials on the second thursday of every month" }
    let(:occurs) { n.occurrences.first }

    it "has a message" do
      expect(n.message).to eq "drink specials"
    end

    it "is day monthly" do
      expect(occurs.type).to eq :daymonthly
    end

    it "occurs on second thursday of every month" do
      expect(occurs.week_of_month).to eq 2
      expect(occurs.day_of_week).to eq 3
    end

    it "occurs once per month" do
      expect(occurs.interval).to eq 1
    end
  end

  context "passed a date monthly occurrence" do
    let(:n) { Nickel.parse "pay credit card every month on the 22nd" }
    let(:occurs) { n.occurrences.first }

    it "has a message" do
      expect(n.message).to eq "pay credit card"
    end

    it "is date monthly" do
      expect(occurs.type).to eq :datemonthly
    end

    it "occurs on the 22nd of every month" do
      expect(occurs.date_of_month).to eq 22
    end

    it "occurs once per month" do
      expect(occurs.interval).to eq 1
    end
  end

  context "passed multiple occurrences" do
    let(:n) { Nickel.parse "band meeting every monday and wednesday at 2pm" }

    it "has a message" do
      expect(n.message).to eq "band meeting"
    end

    it "has two occurrences" do
      expect(n.occurrences.size).to eq 2
    end

    it "occurs on mondays and wednesdays" do
      days = n.occurrences.collect {|occ| occ.day_of_week}
      expect(days).to include(0)
      expect(days).to include(2)
      expect(days.size).to eq 2
    end

    it "occurs at 2pm on both days" do
      expect(n.occurrences[0].start_time.time).to eq "140000"
      expect(n.occurrences[1].start_time.time).to eq "140000"
    end
  end

  context "passed the current time" do
    it "occurs on a date relative to the current time passed in" do
      n = Nickel.parse "lunch 3 days from now", DateTime.new(2009,05,28)
      expect(n.occurrences.first.start_date.date).to eq "20090531"
    end

    it "raises an error if the current time argument is not a datetime or time object" do
      expect{
        Nickel.parse "lunch 3 days from now", Date.new(2009,05,28)
      }.to raise_error("You must pass in a ruby DateTime or Time class object")
    end
  end
end
