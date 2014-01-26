require 'spec_helper.rb'
require File.expand_path(File.dirname(__FILE__) + "/../lib/nickel")

describe "A single date" do
  before(:all) { @n = Nickel.parse "oct 15 09" }

  it "should have an empty message" do
    expect(@n.message).to be_empty
  end

  it "should have a start date" do
    expect(@n.occurrences.size).to eq 1
    expect(@n.occurrences.first.start_date.date).to eq "20091015"
  end
end

describe "A daily occurrence" do
  before(:all) do
    @n = Nickel.parse "wake up everyday at 11am"
    @occurs = @n.occurrences.first
  end

  it "should have a message" do
    expect(@n.message).to eq "wake up"
  end

  it "should be daily" do
    expect(@occurs.type).to eq :daily
  end

  it "should have a start time" do
    expect(@occurs.start_time.time).to eq "110000"
  end
end


describe "A weekly occurrence" do
  before(:all) do
    @n = Nickel.parse "guitar lessons every tuesday at 5pm"
    @occurs = @n.occurrences.first
  end

  it "should have a message" do
    expect(@n.message).to eq "guitar lessons"
  end

  it "should be weekly" do
    expect(@occurs.type).to eq :weekly
  end


  it "should occur on tuesdays" do
    expect(@occurs.day_of_week).to eq 1
  end

  it "should occur once per week" do
    expect(@occurs.interval).to eq 1
  end

  it "should start at 5pm" do
    expect(@occurs.start_time.time).to eq "170000"
  end

  it "should have a start date" do
    expect(@occurs.start_date).to_not be_nil
  end

  it "should not have an end date" do
    expect(@occurs.end_date).to be_nil
  end
end


describe "A day monthly occurrence" do
  before(:all) do
    @n = Nickel.parse "drink specials on the second thursday of every month"
    @occurs = @n.occurrences.first
  end

  it "should have a message" do
    expect(@n.message).to eq "drink specials"
  end

  it "should be day monthly" do
    expect(@occurs.type).to eq :daymonthly
  end

  it "should occur on second thursday of every month" do
    expect(@occurs.week_of_month).to eq 2
    expect(@occurs.day_of_week).to eq 3
  end

  it "should occur once per month" do
    expect(@occurs.interval).to eq 1
  end
end



describe "A date monthly occurrence" do
  before(:all) do
    @n = Nickel.parse "pay credit card every month on the 22nd"
    @occurs = @n.occurrences.first
  end

  it "should have a message" do
    expect(@n.message).to eq "pay credit card"
  end

  it "should be date monthly" do
    expect(@occurs.type).to eq :datemonthly
  end

  it "should occur on the 22nd of every month" do
    expect(@occurs.date_of_month).to eq 22
  end

  it "should occur once per month" do
    expect(@occurs.interval).to eq 1
  end
end


describe "Multiple occurrences" do
  before(:all) do
    @n = Nickel.parse "band meeting every monday and wednesday at 2pm"
  end

  it "should have a message" do
    expect(@n.message).to eq "band meeting"
  end

  it "should have two occurrences" do
    expect(@n.occurrences.size).to eq 2
  end

  it "should occur on mondays and wednesdays" do
    days = @n.occurrences.collect {|occ| occ.day_of_week}
    expect(days).to include(0)
    expect(days).to include(2)
    expect(days.size).to eq 2
  end

  it "should occur at 2pm on both days" do
    expect(@n.occurrences[0].start_time.time).to eq "140000"
    expect(@n.occurrences[1].start_time.time).to eq "140000"
  end
end

describe "Setting current time" do

  it "should occur on a date relative to the current time passed in" do
    n = Nickel.parse "lunch 3 days from now", DateTime.new(2009,05,28)
    expect(n.occurrences.first.start_date.date).to eq "20090531"
  end

  it "should raise an error if the current time argument is not a datetime or time object" do
    expect{
      Nickel.parse "lunch 3 days from now", Date.new(2009,05,28)
    }.to raise_error("You must pass in a ruby DateTime or Time class object")
  end
end

