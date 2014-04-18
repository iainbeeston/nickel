require 'spec_helper'
require 'time'
require_relative '../../lib/nickel'
require_relative '../../lib/nickel/occurrence'
require_relative '../../lib/nickel/zdate'
require_relative '../../lib/nickel/ztime'

describe Nickel do
  describe '#parse' do
    let(:n) { Nickel.parse(query, run_date) }
    let(:run_date) { Time.now }

    context "when the query is 'oct 15 09'" do
      let(:query) { 'oct 15 09' }

      describe '#message' do
        it 'is empty' do
          expect(n.message).to be_empty
        end
      end

      describe '#occurrences' do
        it 'is October 15 2009' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20091015'))
          ]
        end
      end
    end

    context "when the query is 'wake up everyday at 11am'" do
      let(:query) { 'wake up everyday at 11am' }
      let(:run_date) { Time.local(2014, 2, 26) }

      describe '#message' do
        it "is 'wake up'" do
          expect(n.message).to eq 'wake up'
        end
      end

      describe '#occurrences' do
        it 'is daily at 11:00am' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20140226'), start_time: Nickel::ZTime.new('11'))
          ]
        end
      end
    end

    context "when the query is 'guitar lessons every tuesday at 5pm'" do
      let(:query) { 'guitar lessons every tuesday at 5pm' }
      let(:run_date) { Time.local(2014, 2, 26) }

      describe '#message' do
        it "is 'guitar lessons'" do
          expect(n.message).to eq 'guitar lessons'
        end
      end

      describe '#occurrences' do
        it 'is weekly at 5:00pm on Tuesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, interval: 1, day_of_week: 1, start_time: Nickel::ZTime.new('17'), start_date: Nickel::ZDate.new('20140304'))
          ]
        end
      end
    end

    context "when the query is 'drink specials on the second thursday of every month'" do
      let(:query) { 'drink specials on the second thursday of every month' }
      let(:run_date) { Time.local(2014, 2, 26) }

      describe '#message' do
        it "is 'drink specials'" do
          expect(n.message).to eq 'drink specials'
        end
      end

      describe '#occurrences' do
        it 'is monthly on the second Thursday of the month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daymonthly, interval: 1, week_of_month: 2, day_of_week: 3, start_date: Nickel::ZDate.new('20140313'))
          ]
        end
      end
    end

    context "when the query is 'pay credit card every month on the 22nd'" do
      let(:query) { 'pay credit card every month on the 22nd' }
      let(:run_date) { Time.local(2014, 2, 26) }

      describe '#message' do
        it 'is pay credit card' do
          expect(n.message).to eq 'pay credit card'
        end
      end

      describe '#occurrences' do
        it 'is monthly on the 22nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :datemonthly, interval: 1, date_of_month: 22, start_date: Nickel::ZDate.new('20140322'))
          ]
        end
      end
    end

    context "when the query is 'band meeting every monday and wednesday at 2pm'" do
      let(:query) { 'band meeting every monday and wednesday at 2pm' }
      let(:run_date) { Time.local(2014, 2, 26) }

      describe '#message' do
        it "is 'band meeting'" do
          expect(n.message).to eq 'band meeting'
        end
      end

      describe '#occurrences' do
        it 'is Mondays at 2:00pm and Wednesdays at 2:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, interval: 1, day_of_week: 0, start_time: Nickel::ZTime.new('14'), start_date: Nickel::ZDate.new('20140303')),
            Nickel::Occurrence.new(type: :weekly, interval: 1, day_of_week: 2, start_time: Nickel::ZTime.new('14'), start_date: Nickel::ZDate.new('20140226'))
          ]
        end
      end
    end

    context "when the query is 'lunch 3 days from now'" do
      let(:query) { 'lunch 3 days from now' }
      let(:run_date) { Time.local(2009, 05, 28) }

      describe '#message' do
        it "is 'lunch'" do
          expect(n.message).to eq 'lunch'
        end
      end

      describe '#occurrences' do
        it 'is 3 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090531'))
          ]
        end
      end
    end

    context "when the query is 'do something today'" do
      let(:query) { 'do something today' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'do something'" do
          expect(n.message).to eq 'do something'
        end
      end

      describe '#occurrences' do
        it 'is today' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'))
          ]
        end
      end
    end

    context "when the query is 'there is a movie today at noon'" do
      let(:query) { 'there is a  movie today at noon' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'there is a movie'" do
          expect(n.message).to eq 'there is a movie'
        end
      end

      describe '#occurrences' do
        it 'is today at noon' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'), start_time: Nickel::ZTime.new('12'))
          ]
        end
      end
    end

    context "when the query is 'go to work today and tomorrow'" do
      let(:query) { 'go to work today and tomorrow' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'go to work'" do
          expect(n.message).to eq 'go to work'
        end
      end

      describe '#occurrences' do
        it 'is today and tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080826'))
          ]
        end
      end
    end

    context "when the query is 'appointments with the dentist are on oct 5 and oct 23rd'" do
      let(:query) { 'appointments with the dentist are on oct 5 and oct 23rd' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'appointments with the dentist'" do
          expect(n.message).to eq 'appointments with the dentist'
        end
      end

      describe '#occurrences' do
        it 'is October 5 and October 23' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081005')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081023'))
          ]
        end
      end
    end

    context "when the query is 'today at noon and tomorrow at 5:45 am there will be an office meeting'" do
      let(:query) { 'today at noon and tomorrow at 5:45 am there will be an office meeting' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'there will be an office meeting'" do
          expect(n.message).to eq 'there will be an office meeting'
        end
      end

      describe '#occurrences' do
        it 'is noon today and 5:45am tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'), start_time: Nickel::ZTime.new('12')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080826'), start_time: Nickel::ZTime.new('0545'))
          ]
        end
      end
    end

    context "when the query is 'some stuff to do at noon today and 545am tomorrow'" do
      let(:query) { 'some stuff to do at noon today and 545am tomorrow' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'some stuff to do'" do
          expect(n.message).to eq 'some stuff to do'
        end
      end

      describe '#occurrences' do
        it 'is noon today and 5:45am tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'), start_time: Nickel::ZTime.new('12')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080826'), start_time: Nickel::ZTime.new('0545'))
          ]
        end
      end
    end

    context "when the query is 'go to the park tomorrow and thursday with the dog'" do
      let(:query) { 'go to the park tomorrow and thursday with the dog' }
      let(:run_date) { Time.local(2008, 2, 29) }

      describe '#message' do
        it "is 'go to the park with the dog'" do
          expect(n.message).to eq 'go to the park with the dog'
        end
      end

      describe '#occurrences' do
        it 'is tomorrow and thursday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080301')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080306'))
          ]
        end
      end
    end

    context "when the query is 'go to the park tomorrow and also on thursday with the dog'" do
      let(:query) { 'go to the park tomorrow and also on thursday with the dog' }
      let(:run_date) { Time.local(2008, 2, 29) }

      describe '#message' do
        it "is 'go to the park with the dog'" do
          expect(n.message).to eq 'go to the park with the dog'
        end
      end

      describe '#occurrences' do
        it 'is tomorrow and thursday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080301')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080306'))
          ]
        end
      end
    end

    context "when the query is 'how awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this?'" do
      let(:query) { 'how awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this?' }
      let(:run_date) { Time.local(2008, 2, 29) }

      describe '#message' do
        it "is 'how awesome is this?'" do
          expect(n.message).to eq 'how awesome is this?'
        end
      end

      describe '#occurrences' do
        it 'is 1:00am and 2:00am-5:00pm tomorrow and 1:00pm Thursday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080301'), start_time: Nickel::ZTime.new('01')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080301'), start_time: Nickel::ZTime.new('02'), end_time: Nickel::ZTime.new('17')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080306'), start_time: Nickel::ZTime.new('13'))
          ]
        end
      end
    end

    context "when the query is 'soccer practice monday tuesday and wednesday with susan'" do
      let(:query) { 'soccer practice monday tuesday and wednesday with susan' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#message' do
        it "is 'soccer practice with susan'" do
          expect(n.message).to eq 'soccer practice with susan'
        end
      end

      describe '#occurrences' do
        it 'is Monday, Tuesday and Wednesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080915')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080916')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080917'))
          ]
        end
      end
    end

    context "when the query is 'monday and wednesday at 4pm I have guitar lessons'" do
      let(:query) { 'monday and wednesday at 4pm I have guitar lessons' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#message' do
        it "is 'I have guitar lessons'" do
          expect(n.message).to eq 'I have guitar lessons'
        end
      end

      describe '#occurrences' do
        it 'is 4:00pm Monday and 4:00pm Wednesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080915'), start_time: Nickel::ZTime.new('16')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080917'), start_time: Nickel::ZTime.new('16'))
          ]
        end
      end
    end

    context "when the query is 'meet with so and so 4pm on monday and wednesday'" do
      let(:query) { 'meet with so and so 4pm on monday and wednesday' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#message' do
        it "is 'meet with so and so'" do
          expect(n.message).to eq 'meet with so and so'
        end
      end

      describe '#occurrences' do
        it 'is 4:00pm Monday and 4:00pm Wednesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080915'), start_time: Nickel::ZTime.new('16')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080917'), start_time: Nickel::ZTime.new('16'))
          ]
        end
      end
    end

    context "when the query is 'flight this sunday on American'" do
      let(:query) { 'flight this sunday on American' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#message' do
        it "is 'flight on American'" do
          expect(n.message).to eq 'flight on American'
        end
      end

      describe '#occurrences' do
        it 'is this Sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080831'))
          ]
        end
      end
    end

    context "when the query is 'Flight to Miami this sunday 9-5am on Jet Blue'" do
      let(:query) { 'Flight to Miami this sunday 9-5am on Jet Blue' }
      let(:run_date) { Time.local(2007, 11, 25) }

      describe '#message' do
        it "is 'Flight to Miami on Jet Blue'" do
          expect(n.message).to eq 'Flight to Miami on Jet Blue'
        end
      end

      describe '#occurrences' do
        it 'is 9:00pm to 5:00am this Sunday' do
          # FIXME: this occurrence should have an end date
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20071125'), start_time: Nickel::ZTime.new('21'), end_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is 'Go to the park this sunday 9-5'" do
      let(:query) { 'Go to the park this sunday 9-5' }
      let(:run_date) { Time.local(2007, 11, 25) }

      describe '#message' do
        it "is 'Go to the park'" do
          expect(n.message).to eq 'Go to the park'
        end
      end

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm this Sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20071125'), start_time: Nickel::ZTime.new('09'), end_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'movie showings are today at 10, 11, 12, and 1 to 5'" do
      let(:query) { 'movie showings are today at 10, 11, 12, and 1 to 5' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#message' do
        it "is 'movie showings'" do
          expect(n.message).to eq 'movie showings'
        end
      end

      describe '#occurrences' do
        it 'is 10:00am, 11:00am, 12:00pm and 1:00pm to 5:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('10')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('11')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('12')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('13'), end_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'Games today at 10, 11, 12, 1'" do
      let(:query) { 'Games today at 10, 11, 12, 1' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#message' do
        it "is 'Games'" do
          expect(n.message).to eq 'Games'
        end
      end

      describe '#occurrences' do
        it 'is 10:00am, 11:00am, 12:00pm and 1:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('10')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('11')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('12')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('13'))
          ]
        end
      end
    end

    context "when the query is 'Flight is a week from today'" do
      let(:query) { 'Flight is a week from today' }
      let(:run_date) { Time.local(2009, 1, 1) }

      describe '#message' do
        it "is 'Flight'" do
          expect(n.message).to eq 'Flight'
        end
      end

      describe '#occurrences' do
        it 'is a week from today' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090108'))
          ]
        end
      end
    end

    context "when the query is 'Bill is due two weeks from tomorrow'" do
      let(:query) { 'Bill is due two weeks from tomorrow' }
      let(:run_date) { Time.local(2008, 12, 24) }

      describe '#message' do
        it "is 'Bill is due'" do
          expect(n.message).to eq 'Bill is due'
        end
      end

      describe '#occurrences' do
        it 'is two weeks from tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090108'))
          ]
        end
      end
    end

    context "when the query is 'Tryouts are two months from now'" do
      let(:query) { 'Tryouts are two months from now' }
      let(:run_date) { Time.local(2008, 12, 24) }

      describe '#message' do
        it "is 'Tryouts'" do
          expect(n.message).to eq 'Tryouts'
        end
      end

      describe '#occurrences' do
        it 'is two months from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090224'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on october second'" do
      let(:query) { 'baseball game is on october second' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#message' do
        it "is 'baseball game'" do
          expect(n.message).to eq 'baseball game'
        end
      end

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on 10/2'" do
      # FIXME: n should support US and international date formats
      let(:query) { 'baseball game is on 10/2' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on 10/2/08'" do
      let(:query) { 'baseball game is on 10/2/08' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on 10/2/2008'" do
      let(:query) { 'baseball game is on 10/2/2008' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on october 2nd 08'" do
      let(:query) { 'baseball game is on october 2nd 08' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'baseball game is on october 2nd 2008'" do
      let(:query) { 'baseball game is on october 2nd 2008' }
      let(:run_date) { Time.local(2008, 1, 30) }

      describe '#occurrences' do
        it 'is October 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'something for the next 1 day'" do
      let(:query) { 'something for the next 1 day' }
      let(:run_date) { Time.local(2007, 12, 29) }

      describe '#message' do
        it "is 'something'" do
          expect(n.message).to eq 'something'
        end
      end

      describe '#occurrences' do
        it 'is today and tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20071229'), end_date: Nickel::ZDate.new('20071230'))
          ]
        end
      end
    end

    context "when the query is 'pick up groceries tomorrow and also the kids'" do
      let(:query) { 'pick up groceries tomorrow and also the kids' }
      let(:run_date) { Time.local(2008, 10, 28) }

      describe '#message' do
        it "is 'pick up groceries and also the kids'" do
          expect(n.message).to eq 'pick up groceries and also the kids'
        end
      end

      describe '#occurrences' do
        it 'is tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081029'))
          ]
        end
      end
    end

    context "when the query is 'do something on january first'" do
      let(:query) { 'do something on january first' }
      let(:run_date) { Time.local(2008, 11, 30) }

      describe '#message' do
        it "is 'do something'" do
          expect(n.message).to eq 'do something'
        end
      end

      describe '#occurrences' do
        it 'is January 1st' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090101'))
          ]
        end
      end
    end

    context "when the query is 'on the first of the month, go to the museum'" do
      let(:query) { 'on the first of the month, go to the museum' }
      let(:run_date) { Time.local(2008, 11, 30) }

      describe '#message' do
        it "is 'go to the museum'" do
          expect(n.message).to eq 'go to the museum'
        end
      end

      describe '#occurrences' do
        it 'is the 1st of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081201'))
          ]
        end
      end
    end

    context "when the query is 'today from 8 to 4 and 9 to 5'" do
      let(:query) { 'today from 8 to 4 and 9 to 5' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#occurrences' do
        it 'is 8:00am to 4:00pm and 9:00am to 5:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('08'), end_time: Nickel::ZTime.new('16')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('09'), end_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'today from 9 to 5pm and 8am to 4'" do
      let(:query) { 'today from 9 to 5pm and 8am to 4' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm and 8:00am to 4:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('08'), end_time: Nickel::ZTime.new('16')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('09'), end_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'today at 11am, 2 and 3, and tomorrow from 2 to 6pm'" do
      let(:query) { 'today at 11am, 2 and 3, and tomorrow from 2 to 6pm' }
      let(:run_date) { Time.local(2008, 9, 10) }

      describe '#occurrences' do
        it 'is 11:00am, 2:00pm, 3:00pm, 2:00pm to 6:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('11')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('14')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080910'), start_time: Nickel::ZTime.new('15')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080911'), start_time: Nickel::ZTime.new('14'), end_time: Nickel::ZTime.new('18'))
          ]
        end
      end
    end

    context "when the query is 'next monday'" do
      let(:query) { 'next monday' }
      let(:run_date) { Time.local(2008, 10, 27) }

      describe '#occurrences' do
        it 'is next monday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081103'))
          ]
        end
      end
    end

    context "when the query is 'last monday this month'" do
      let(:query) { 'last monday this month' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#occurrences' do
        it 'is last monday this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'))
          ]
        end
      end
    end

    context "when the query is 'the last monday of this month'" do
      let(:query) { 'the last monday of this month' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#occurrences' do
        it 'is last monday this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080825'))
          ]
        end
      end
    end

    context "when the query is 'the last thursday of the month'" do
      let(:query) { 'the last thursday of the month' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#occurrences' do
        it 'is last thursday this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080828'))
          ]
        end
      end
    end

    context "when the query is 'third monday next month'" do
      let(:query) { 'third monday next month' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#occurrences' do
        it 'is third monday last month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080915'))
          ]
        end
      end
    end

    context "when the query is 'the third monday next month'" do
      let(:query) { 'the third monday next month' }
      let(:run_date) { Time.local(2008, 8, 25) }

      describe '#occurrences' do
        it 'is third monday last month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080915'))
          ]
        end
      end
    end

    context "when the query is 'the twentyeigth'" do
      let(:query) { 'the twentyeigth' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is '28th'" do
      let(:query) { '28th' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is '28'" do
      let(:query) { '28' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is 'the 28th of this month'" do
      let(:query) { 'the 28th of this month' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is '28th of this month'" do
      let(:query) { '28th of this month' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is 'the 28th this month'" do
      let(:query) { 'the 28th this month' }
      let(:run_date) { Time.local(2010, 3, 20) }

      describe '#occurrences' do
        it 'is the 28th of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20100328'))
          ]
        end
      end
    end

    context "when the query is 'next month 28th'" do
      let(:query) { 'next month 28th' }
      let(:run_date) { Time.local(2008, 12, 31) }

      describe '#occurrences' do
        it 'is the 28th of next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090128'))
          ]
        end
      end
    end

    context "when the query is '28th next month'" do
      let(:query) { '28th next month' }
      let(:run_date) { Time.local(2008, 12, 31) }

      describe '#occurrences' do
        it 'is the 28th of next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090128'))
          ]
        end
      end
    end

    context "when the query is 'the 28th next month'" do
      let(:query) { 'the 28th next month' }
      let(:run_date) { Time.local(2008, 12, 31) }

      describe '#occurrences' do
        it 'is the 28th of next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090128'))
          ]
        end
      end
    end

    context "when the query is '28th of next month'" do
      let(:query) { '28th of next month' }
      let(:run_date) { Time.local(2008, 12, 31) }

      describe '#occurrences' do
        it 'is the 28th of next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090128'))
          ]
        end
      end
    end

    context "when the query is 'the 28th of next month'" do
      let(:query) { 'the 28th of next month' }
      let(:run_date) { Time.local(2008, 12, 31) }

      describe '#occurrences' do
        it 'is the 28th of next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090128'))
          ]
        end
      end
    end

    context "when the query is '6 days from tomorrow'", :broken do
      let(:query) { '6 days from tomorrow' }
      let(:run_date) { Time.local(2014, 2, 12) }

      describe '#occurrences' do
        it 'is 7 days from now' do
          # returns only tomorrow, with the message '6 days'
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140218'))
          ]
        end
      end
    end

    context "when the query is '5 days from now'" do
      let(:query) { '5 days from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080916'))
          ]
        end
      end
    end

    context "when the query is 'in 5 days'" do
      let(:query) { 'in 5 days' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080916'))
          ]
        end
      end
    end

    context "when the query is '5 weeks from now'" do
      let(:query) { '5 weeks from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 weeks from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081016'))
          ]
        end
      end
    end

    context "when the query is 'in 5 weeks'" do
      let(:query) { 'in 5 weeks' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 weeks from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20081016'))
          ]
        end
      end
    end

    context "when the query is '5 months from now'" do
      let(:query) { '5 months from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 months from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090211'))
          ]
        end
      end
    end

    context "when the query is 'in 5 months'" do
      let(:query) { 'in 5 months' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 months from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090211'))
          ]
        end
      end
    end

    context "when the query is '5 minutes from now'" do
      let(:query) { '5 minutes from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 minutes from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080911'), start_time: Nickel::ZTime.new('0005'))
          ]
        end
      end
    end

    context "when the query is 'in 5 minutes'" do
      let(:query) { 'in 5 minutes' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 minutes from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080911'), start_time: Nickel::ZTime.new('0005'))
          ]
        end
      end
    end

    context "when the query is '5 hours from now'" do
      let(:query) { '5 hours from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 hours from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080911'), start_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is 'in 5 hours'" do
      let(:query) { 'in 5 hours' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 5 hours from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080911'), start_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is '24 hours from now'" do
      let(:query) { '24 hours from now' }
      let(:run_date) { Time.local(2008, 9, 11) }

      describe '#occurrences' do
        it 'is 24 hours from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080912'), start_time: Nickel::ZTime.new('000000'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow through sunday'" do
      let(:query) { 'tomorrow through sunday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is tomorrow to sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20080919'), end_date: Nickel::ZDate.new('20080921'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'tomorrow through sunday from 9 to 5'" do
      let(:query) { 'tomorrow through sunday from 9 to 5' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm every day from tomorrow to sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20080919'), end_date: Nickel::ZDate.new('20080921'), start_time: Nickel::ZTime.new('09'), end_time: Nickel::ZTime.new('17'), interval: 1)
          ]
        end
      end
    end

    context "when the query is '9 to 5 tomorrow through sunday'" do
      let(:query) { '9 to 5 tomorrow through sunday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm every day from tomorrow to sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20080919'), end_date: Nickel::ZDate.new('20080921'), start_time: Nickel::ZTime.new('09'), end_time: Nickel::ZTime.new('17'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'october 2nd through 5th'" do
      let(:query) { 'october 2nd through 5th' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'october 2nd through october 5th'" do
      let(:query) { 'october 2nd through october 5th' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is '10/2 to 10/5'" do
      let(:query) { '10/2 to 10/5' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'oct 2 until 5'" do
      let(:query) { 'oct 2 until 5' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'oct 2 until oct 5'" do
      let(:query) { 'oct 2 until oct 5' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'oct 2-oct 5'" do
      let(:query) { 'oct 2-oct 5' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'october 2nd-5th'" do
      let(:query) { 'october 2nd-5th' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'october 2nd-5th from 9 to 5am'" do
      let(:query) { 'october 2nd-5th from 9 to 5am' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1, start_time: Nickel::ZTime.new('21'), end_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is 'october 2nd-5th every day from 9 to 5am'" do
      let(:query) { 'october 2nd-5th every day from 9 to 5am' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is 9:00am to 5:00pm every day from October 2nd to October 5th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081005'), interval: 1, start_time: Nickel::ZTime.new('21'), end_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is 'january 1 from 1PM to 5AM'" do
      let(:query) { 'january 1 from 1PM to 5AM' }
      let(:run_date) { Time.local(2013, 1, 25) }

      describe '#occurrences' do
        it 'is 1:00pm to 5:00am January 1st' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20130101'), start_time: Nickel::ZTime.new('13'), end_time: Nickel::ZTime.new('05'))
          ]
        end
      end
    end

    context "when the query is 'tuesday, january 1st - friday, february 15, 2013'" do
      let(:query) { 'tuesday, january 1st - friday, february 15, 2013' }
      let(:run_date) { Time.local(2008, 1, 25) }

      describe '#occurrences' do
        it 'is every day from January 1st to February 15th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20130101'), end_date: Nickel::ZDate.new('20130215'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'tuesday, january 1, 2013 - friday, february 15, 2013'" do
      let(:query) { 'tuesday, january 1, 2013 - friday, february 15, 2013' }
      let(:run_date) { Time.local(2008, 1, 25) }

      describe '#occurrences' do
        it 'is every day from January 1st to February 15th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20130101'), end_date: Nickel::ZDate.new('20130215'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'every monday and wednesday'" do
      let(:query) { 'every monday and wednesday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every Monday and Wednesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080922')),
            Nickel::Occurrence.new(type: :weekly, day_of_week: 2, interval: 1, start_date: Nickel::ZDate.new('20080924'))
          ]
        end
      end
    end

    context "when the query is 'every other monday and wednesday'" do
      let(:query) { 'every other monday and wednesday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every other Monday and Wednesday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 2, start_date: Nickel::ZDate.new('20080922')),
            Nickel::Occurrence.new(type: :weekly, day_of_week: 2, interval: 2, start_date: Nickel::ZDate.new('20080924'))
          ]
        end
      end
    end

    context "when the query is 'every monday'" do
      let(:query) { 'every monday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every Monday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080922'))
          ]
        end
      end
    end

    context "when the query is 'every monday at 2pm and wednesday at 4pm'", :broken do
      let(:query) { 'every monday at 2pm and wednesday at 4pm' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every Monday at 2:00pm and every Wednesday at 4:00pm' do
          # returns only monday at 2pm
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080922'), start_time: Nickel::ZTime.new('14')),
            Nickel::Occurrence.new(type: :weekly, day_of_week: 2, interval: 1, start_date: Nickel::ZDate.new('20080924'), start_time: Nickel::ZTime.new('16'))
          ]
        end
      end
    end

    context "when the query is 'every monday at 2pm and every wednesday at 4pm'" do
      let(:query) { 'every monday at 2pm and every wednesday at 4pm' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every Monday at 2:00pm and every Wednesday at 4:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080922'), start_time: Nickel::ZTime.new('14')),
            Nickel::Occurrence.new(type: :weekly, day_of_week: 2, interval: 1, start_date: Nickel::ZDate.new('20080924'), start_time: Nickel::ZTime.new('16'))
          ]
        end
      end
    end

    context "when the query is 'every monday every wednesday'" do
      let(:query) { 'every monday every wednesday' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is every Monday at 2:00pm and every Wednesday at 4:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080922')),
            Nickel::Occurrence.new(type: :weekly, day_of_week: 2, interval: 1, start_date: Nickel::ZDate.new('20080924'))
          ]
        end
      end
    end

    context "when the query is 'the 22nd of every month'" do
      let(:query) { 'the 22nd of every month' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is the 22nd of every month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :datemonthly, date_of_month: 22, interval: 1, start_date: Nickel::ZDate.new('20080922'))
          ]
        end
      end
    end

    context "when the query is 'the first friday of every month'" do
      let(:query) { 'the first friday of every month' }
      let(:run_date) { Time.local(2008, 9, 18) }

      describe '#occurrences' do
        it 'is the first friday of every month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daymonthly, week_of_month: 1, day_of_week: 4, interval: 1, start_date: Nickel::ZDate.new('20081003'))
          ]
        end
      end
    end

    context "when the query is 'the second tuesday of every month at 5pm'" do
      let(:query) { 'the second tuesday of every month at 5pm' }
      let(:run_date) { Time.local(2008, 9, 24) }

      describe '#occurrences' do
        it 'is 5:00pm on the second Tuesday of every month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daymonthly, week_of_month: 2, day_of_week: 1, interval: 1, start_date: Nickel::ZDate.new('20081014'), start_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'the first tuesday of every month at 4pm and 5pm, the second tuesday of every month at 5pm'" do
      let(:query) { 'the first tuesday of every month at 4pm and 5pm, the second tuesday of every month at 5pm' }
      let(:run_date) { Time.local(2008, 9, 24) }

      describe '#occurrences' do
        it 'is 4:00pm to 5:00pm on the first Tuesday of every month and 5:00pm on the second Tuesday of every month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daymonthly, week_of_month: 1, day_of_week: 1, interval: 1, start_date: Nickel::ZDate.new('20081007'), start_time: Nickel::ZTime.new('16')),
            Nickel::Occurrence.new(type: :daymonthly, week_of_month: 1, day_of_week: 1, interval: 1, start_date: Nickel::ZDate.new('20081007'), start_time: Nickel::ZTime.new('17')),
            Nickel::Occurrence.new(type: :daymonthly, week_of_month: 2, day_of_week: 1, interval: 1, start_date: Nickel::ZDate.new('20081014'), start_time: Nickel::ZTime.new('17'))
          ]
        end
      end
    end

    context "when the query is 'every sunday in december'" do
      let(:query) { 'every sunday in december' }
      let(:run_date) { Time.local(2008, 9, 24) }

      describe '#occurrences' do
        it 'is every Sunday in December' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 6, interval: 1, start_date: Nickel::ZDate.new('20081207'), end_date: Nickel::ZDate.new('20081228'))
          ]
        end
      end
    end

    context "when the query is 'every monday until december'" do
      let(:query) { 'every monday until december' }
      let(:run_date) { Time.local(2008, 9, 24) }

      describe '#occurrences' do
        it 'is every Monday from now until December' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20080929'), end_date: Nickel::ZDate.new('20081124'))
          ]
        end
      end
    end

    context "when the query is 'every monday next month'" do
      let(:query) { 'every monday next month' }
      let(:run_date) { Time.local(2008, 9, 24) }

      describe '#occurrences' do
        it 'is every Monday next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, day_of_week: 0, interval: 1, start_date: Nickel::ZDate.new('20081006'), end_date: Nickel::ZDate.new('20081027'))
          ]
        end
      end
    end

    context "when the query is 'everyday next month'" do
      let(:query) { 'everyday next month' }
      let(:run_date) { Time.local(2008, 12, 24) }

      describe '#occurrences' do
        it 'is every day next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20090101'), end_date: Nickel::ZDate.new('20090131'))
          ]
        end
      end
    end

    context "when the query is 'in the next two days'" do
      let(:query) { 'in the next two days' }
      let(:run_date) { Time.local(2007, 12, 29) }

      describe '#occurrences' do
        it 'is today, tomorrow and the day after' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20071229'), end_date: Nickel::ZDate.new('20071231'))
          ]
        end
      end
    end

    context "when the query is 'for three days'" do
      let(:query) { 'for three days' }
      let(:run_date) { Time.local(2007, 12, 29) }

      describe '#occurrences' do
        it 'is today, tomorrow, the day after and the day after that' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20071229'), end_date: Nickel::ZDate.new('20080101'))
          ]
        end
      end
    end

    context "when the query is 'for the next three days'" do
      let(:query) { 'for the next three days' }
      let(:run_date) { Time.local(2007, 12, 29) }

      describe '#occurrences' do
        it 'is today, tomorrow, the day after and the day after that' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20071229'), end_date: Nickel::ZDate.new('20080101'))
          ]
        end
      end
    end

    context "when the query is 'this week'" do
      let(:query) { 'this week' }
      let(:run_date) { Time.local(2008, 9, 25) }

      describe '#occurrences' do
        it 'is every day from now until 7 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20080925'), end_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'every day this week'" do
      let(:query) { 'every day this week' }
      let(:run_date) { Time.local(2008, 9, 25) }

      describe '#occurrences' do
        it 'is every day from now until 7 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20080925'), end_date: Nickel::ZDate.new('20081002'))
          ]
        end
      end
    end

    context "when the query is 'next week'" do
      let(:query) { 'next week' }
      let(:run_date) { Time.local(2008, 9, 25) }

      describe '#occurrences' do
        it 'is every day from 7 days from now until 14 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081009'))
          ]
        end
      end
    end

    context "when the query is 'every day next week'" do
      let(:query) { 'every day next week' }
      let(:run_date) { Time.local(2008, 9, 25) }

      describe '#occurrences' do
        it 'is every day from 7 days from now until 14 days from now' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20081002'), end_date: Nickel::ZDate.new('20081009'))
          ]
        end
      end
    end

    context "when the query is 'for five weeks'" do
      let(:query) { 'for five weeks' }
      let(:run_date) { Time.local(2014, 2, 12) }

      describe '#occurrences' do
        it 'is every day for the next 35 days' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, interval: 1, start_date: Nickel::ZDate.new('20140212'), end_date: Nickel::ZDate.new('20140319'))
          ]
        end
      end
    end

    context "when the query is 'all month'" do
      let(:query) { 'all month' }
      let(:run_date) { Time.local(2008, 10, 5) }

      describe '#occurrences' do
        it 'is every day from now until the last day of the month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081005'), end_date: Nickel::ZDate.new('20081031'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'the week of jan 2nd'" do
      let(:query) { 'the week of jan 2nd' }
      let(:run_date) { Time.local(2008, 12, 21) }

      describe '#occurrences' do
        it 'is every day in the 7 days starting on January 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20090102'), end_date: Nickel::ZDate.new('20090109'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'the week ending jan 2nd'" do
      let(:query) { 'the week ending jan 2nd' }
      let(:run_date) { Time.local(2008, 12, 21) }

      describe '#occurrences' do
        it 'is every day in the 7 days preceeding January 2nd' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081226'), end_date: Nickel::ZDate.new('20090102'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'the week of the 22nd'" do
      let(:query) { 'the week of the 22nd' }
      let(:run_date) { Time.local(2008, 12, 21) }

      describe '#occurrences' do
        it 'is every day in the 7 days starting on the 22nd of this month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081222'), end_date: Nickel::ZDate.new('20081229'), interval: 1)
          ]
        end
      end
    end

    context "when the query is 'this monday, wednesday, friday and saturday'" do
      let(:query) { 'this monday, wednesday, friday and saturday' }
      let(:run_date) { Time.local(2014, 2, 9) }

      describe '#occurrences' do
        it 'is the following Monday, Wednesday, Friday and Saturday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140210')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140212')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140214')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140215'))
          ]
        end
      end
    end

    context "when the query is 'monday, wednesday, friday and saturday'" do
      let(:query) { 'monday, wednesday, friday and saturday' }
      let(:run_date) { Time.local(2014, 2, 9) }

      describe '#occurrences' do
        it 'is the following Monday, Wednesday, Friday and Saturday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140210')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140212')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140214')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140215'))
          ]
        end
      end
    end

    context "when the query is 'next monday, wednesday, friday and saturday'" do
      let(:query) { 'next monday, wednesday, friday and saturday' }
      let(:run_date) { Time.local(2014, 2, 9) }

      describe '#occurrences' do
        it 'is the next Monday, Wednesday, Friday and Saturday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140217')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140219')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140221')),
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140222'))
          ]
        end
      end
    end

    context "when the query is 'october 2nd, 2009'" do
      let(:query) { 'october 2nd, 2009' }
      let(:run_date) { Time.local(2008, 1, 1) }

      describe '#occurrences' do
        it 'is October 2nd 2009' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20091002'))
          ]
        end
      end
    end

    context "when the query is 'April 29, 5-8pm'" do
      let(:query) { 'April 29, 5-8pm' }
      let(:run_date) { Time.local(2008, 3, 30) }

      describe '#occurrences' do
        it 'is 5:00pm to 8:00pm on April 29th' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20080429'), start_time: Nickel::ZTime.new('17'), end_time: Nickel::ZTime.new('20'))
          ]
        end
      end
    end

    context "when the query is 'the first of each month'" do
      let(:query) { 'the first of each month' }
      let(:run_date) { Time.local(2008, 1, 1) }

      describe '#occurrences' do
        it 'is every 1st of the month starting next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :datemonthly, start_date: Nickel::ZDate.new('20080101'), interval: 1, date_of_month: 1)
          ]
        end
      end
    end

    context "when the query is 'the first of each month'" do
      let(:query) { 'the first of each month' }
      let(:run_date) { Time.local(2009, 2, 15) }

      describe '#occurrences' do
        it 'is every 1st of the month starting next month' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :datemonthly, start_date: Nickel::ZDate.new('20090301'), interval: 1, date_of_month: 1)
          ]
        end
      end
    end

    context "when the query is 'every sunday'" do
      let(:query) { 'every sunday' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every sunday' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, start_date: Nickel::ZDate.new('20090104'), interval: 1, day_of_week: 6)
          ]
        end
      end
    end

    context "when the query is 'every month on the 22nd at 2pm'" do
      let(:query) { 'every month on the 22nd at 2pm' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every month on the 22nd at 2:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :datemonthly, start_date: Nickel::ZDate.new('20090122'), interval: 1, date_of_month: 22, start_time: Nickel::ZTime.new('14'))
          ]
        end
      end
    end

    context "when the query is 'every other saturday at noon'" do
      let(:query) { 'every other saturday at noon' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every 2nd Saturday at 12:00pm' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, start_date: Nickel::ZDate.new('20090103'), interval: 2, day_of_week: 5, start_time: Nickel::ZTime.new('12'))
          ]
        end
      end
    end

    context "when the query is 'every day at midnight'" do
      let(:query) { 'every day at midnight' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every day at 12:00am' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081230'), interval: 1, start_time: Nickel::ZTime.new('00'))
          ]
        end
      end
    end

    context "when the query is 'daily from noon to midnight'" do
      let(:query) { 'daily from noon to midnight' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every day from 12:00pm to 12:00am' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081230'), interval: 1, start_time: Nickel::ZTime.new('12'), end_time: Nickel::ZTime.new('00'))
          ]
        end
      end
    end

    context "when the query is 'the last tuesday of every month, starts at 9am'" do
      let(:query) { 'the last tuesday of every month, starts at 9am' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is the last Tuesday of every month at 9:00am' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daymonthly, start_date: Nickel::ZDate.new('20081230'), start_time: Nickel::ZTime.new('09'), interval: 1, week_of_month: -1, day_of_week: 1)
          ]
        end
      end
    end

    context "when the query is 'one week from today'" do
      let(:query) { 'one week from today' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is one week from today' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20090106'))
          ]
        end
      end
    end

    context "when the query is 'every other day at 2:45am'" do
      let(:query) { 'every other day at 2:45am' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every other day at 2:45am' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081230'), start_time: Nickel::ZTime.new('0245'), interval: 2)
          ]
        end
      end
    end

    context "when the query is 'every other day at 2:45am starting tomorrow'" do
      let(:query) { 'every other day at 2:45am starting tomorrow' }
      let(:run_date) { Time.local(2008, 12, 30) }

      describe '#occurrences' do
        it 'is every other day at 2:45am starting from tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20081231'), start_time: Nickel::ZTime.new('0245'), interval: 2)
          ]
        end
      end

      context "when the query is 'every third monday starting on this monday'" do
        let(:query) { 'every third monday starting on this monday' }
        let(:run_date) { Time.local(2014, 2, 14) }

        describe '#occurrences' do
          it 'is every third monday starting from the following monday' do
            expect(n.occurrences).to match_array [
              Nickel::Occurrence.new(type: :weekly, start_date: Nickel::ZDate.new('20140217'), interval: 3, day_of_week: 0)
            ]
          end
        end
      end

      context "when the query is 'every third day starting today'" do
        let(:query) { 'every third day starting today' }
        let(:run_date) { Time.local(2014, 2, 14) }

        describe '#occurrences' do
          it 'is every third day starting from today' do
            expect(n.occurrences).to match_array [
              Nickel::Occurrence.new(type: :daily, start_date: Nickel::ZDate.new('20140214'), interval: 3)
            ]
          end
        end
      end

      context "when the query is 'the last monday of each month for six months'" do
        let(:query) { 'the last monday of each month for six months' }
        let(:run_date) { Time.local(2014, 2, 12) }

        describe '#occurrences' do
          it 'is the last monday of every month for the next six months' do
            expect(n.occurrences).to match_array [
              Nickel::Occurrence.new(type: :daymonthly, interval: 1, day_of_week: 0, week_of_month: -1, start_date: Nickel::ZDate.new('20140224'), end_date: Nickel::ZDate.new('20140812'))
            ]
          end
        end
      end

      context "when the query is '2 weeks from yesterday'" do
        let(:query) { '2 weeks from yesterday' }
        let(:run_date) { Time.local(2014, 2, 12) }

        describe '#occurrences' do
          it 'is 13 days from today' do
            expect(n.occurrences).to match_array [
              Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140225'))
            ]
          end
        end
      end
    end

    context "when the query is 'meeting with Jimmy at 7am'", :broken do
      let(:query) { 'meeting with Jimmy at 7am' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'meeting with Jimmy'" do
          expect(n.message).to eq 'meeting with Jimmy'
        end
      end

      describe '#occurrences' do
        it 'is 7am today' do
          # returns no occurrences at all
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'), start_time: Nickel::ZTime.new('7'))
          ]
        end
      end
    end

    context "when the query is 'meeting at 8 o'clock'", :broken do
      let(:query) { "meeting at 8 o'clock" }
      let(:run_date) { Time.local(2014, 4, 18, 12, 0) }

      describe '#message' do
        it "is 'meeting'" do
          expect(n.message).to eq 'meeting'
        end
      end

      describe '#occurrences' do
        it "is the next 8 o'clock" do
          # returns no occurrences
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'), start_time: Nickel::ZTime.new('20'))
          ]
        end
      end
    end

    context "when the query is 'let's do it today'", :broken do
      let(:query) { "let's do it today" }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'let's do it'" do
          # returns "lets do it" (no apostrophe)
          expect(n.message).to eq "let's do it"
        end
      end

      describe '#occurrences' do
        it 'is today' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'))
          ]
        end
      end
    end

    context "when the query is 'let us do it today'" do
      let(:query) { 'let us do it today' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'let us do it'" do
          expect(n.message).to eq "let us do it"
        end
      end

      describe '#occurrences' do
        it 'is today' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'))
          ]
        end
      end
    end

    context "when the query is 'let us do it today!'", :broken do
      let(:query) { 'let us do it today!' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'let us do it!'" do
          # returns "let us do it today!"
          expect(n.message).to eq 'let us do it!'
        end
      end

      describe '#occurrences' do
        it 'is today' do
          # returns no occurrences
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow morning'", :broken do
      let(:query) { 'tomorrow morning' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#occurrences' do
        it 'is 3am to 12pm tomorrow' do
          # returns tomorrow
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'), start_time: Nickel::ZTime.new('3'), end_time: Nickel::ZTime.new('12'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow afternoon'", :broken do
      let(:query) { 'tomorrow afternoon' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#occurrences' do
        it 'is 12pm to 6pm tomorrow' do
          # returns tomorrow at 12pm
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'), start_time: Nickel::ZTime.new('12'), end_time: Nickel::ZTime.new('18'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow evening'", :broken do
      let(:query) { 'tomorrow evening' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#occurrences' do
        it 'is 6pm to 9pm tomorrow' do
          # returns tomorrow
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'), start_time: Nickel::ZTime.new('18'), end_time: Nickel::ZTime.new('21'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow night'", :broken do
      let(:query) { 'tomorrow night' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#occurrences' do
        it 'is 9pm tomorrow to 3am the day after tomorrow' do
          # returns tomorrow
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'), start_time: Nickel::ZTime.new('9'), end_date: Nickel::ZDate.new('20140420'), end_time: Nickel::ZTime.new('3'))
          ]
        end
      end
    end

    context "when the query is 'let us go dancing at 3 in the morning'", :broken do
      let(:query) { 'let us go dancing at 3 in the morning' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'let us go dancing'" do
          expect(n.message).to eq 'let us go dancing'
        end
      end

      describe '#occurrences' do
        it 'is 3am' do
          # returns no occurrences
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'), start_time: Nickel::ZTime.new('3'))
          ]
        end
      end
    end

    context "when the query is 'let us go dancing on 12/07/2014'" do
      let(:query) { 'let us go dancing on 12/07/2014' }

      describe '#message' do
        it "is 'let us go dancing'" do
          expect(n.message).to eq 'let us go dancing'

        end
      end

      describe '#occurrences' do
        it 'is 7th of December 2014' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20141207'))
          ]
        end
      end
    end

    context "when the query is 'every sunday until 2015", :broken do
      let(:query) { 'every sunday until 2015' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#occurrences' do
        it 'every sunday until the last sunday of 2014' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :weekly, interval: 1, day_of_week: 6, start_date: Nickel::ZDate.new('20140420'), end_date: Nickel::ZDate.new('20141228'))
          ]
        end
      end
    end

    context "when the query is 'give me two cents in 5 minutes'", :broken do
      let(:query) { 'give me two cents in 5 minutes' }
      let(:run_date) { Time.local(2014, 4, 18, 12, 0) }

      describe '#message' do
        it "is 'give me two cents'" do
          # returns give me cents
          expect(n.message).to eq 'give me two cents'
        end
      end

      describe '#occurrences' do
        it 'is 12:05pm' do
          # returns 2am
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140418'), start_time: Nickel::ZTime.new('1205'))
          ]
        end
      end
    end

    context "when the query is 'give me two cents in 3 days'", :broken do
      let(:query) { 'give me two cents in 3 days' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it "is 'give me two cents'" do
          # returns give me cents
          expect(n.message).to eq 'give me two cents'
        end
      end

      describe '#occurrences' do
        it 'is two days from now' do
          # returns 2am 3 days from now
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140421'))
          ]
        end
      end
    end

    context "when the query is 'tomorrow anytime'" do
      let(:query) { 'tomorrow anytime' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it 'is empty' do
          expect(n.message).to be_empty
        end
      end

      describe '#occurrences' do
        it 'is tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'))
          ]
        end
      end
    end

    context "when the query is 'all day tomorrow'" do
      let(:query) { 'all day tomorrow' }
      let(:run_date) { Time.local(2014, 4, 18) }

      describe '#message' do
        it 'is empty' do
          expect(n.message).to be_empty
        end
      end

      describe '#occurrences' do
        it 'is tomorrow' do
          expect(n.occurrences).to match_array [
            Nickel::Occurrence.new(type: :single, start_date: Nickel::ZDate.new('20140419'))
          ]
        end
      end
    end

    context "when the query is 'job search apply at virgin intergalactic'" do
      let(:query) { 'job search apply at virgin intergalactic' }

      describe '#message' do
        it "is 'job search apply at virgin intergalactic'" do
          expect(n.message).to eq 'job search apply at virgin intergalactic'
        end
      end

      describe '#occurrences' do
        it 'is an empty array' do
          expect(n.occurrences).to be_empty
        end
      end
    end

    context "when the query is 'job search - apply at virgin intergalactic'", :broken do
      let(:query) { 'job search - apply at virgin intergalactic' }

      describe '#message' do
        it "is 'job search - apply at virgin intergalactic'" do
          expect(n.message).to eq 'job search - apply at virgin intergalactic'
        end
      end

      describe '#occurrences' do
        it 'is an empty array' do
          # returns every day from today
          expect(n.occurrences).to be_empty
        end
      end
    end
  end
end
