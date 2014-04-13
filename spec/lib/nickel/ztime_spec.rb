require 'spec_helper'
require_relative '../../../lib/nickel/ztime'

module Nickel
  describe ZTime do
    describe '#modify_such_that_is_before' do
      specify '1200 to before 1200am is 1200' do
        expect(ZTime.new('1200').modify_such_that_is_before(ZTime.new('1200', :am))).to eq ZTime.new('1200')
      end

      specify '1200 to before 1200pm is 1200am' do
        expect(ZTime.new('1200').modify_such_that_is_before(ZTime.new('1200', :pm))).to eq ZTime.new('1200', :am)
      end

      specify '1 to before 2am is 1' do
        expect(ZTime.new('1').modify_such_that_is_before(ZTime.new('2', :am))).to eq ZTime.new('1')
      end

      specify '10 to before 11pm is 10pm' do
        expect(ZTime.new('10').modify_such_that_is_before(ZTime.new('11', :pm))).to eq ZTime.new('10', :pm)
      end

      specify '8 to before 11pm is 8' do
        expect(ZTime.new('8').modify_such_that_is_before(ZTime.new('12', :pm))).to eq ZTime.new('8')
      end

      specify '0830 to before 0835am is 0830' do
        expect(ZTime.new('0830').modify_such_that_is_before(ZTime.new('0835', :am))).to eq ZTime.new('0830')
      end

      specify '0830 to before 0835pm is 0830pm' do
        expect(ZTime.new('0830').modify_such_that_is_before(ZTime.new('0835', :pm))).to eq ZTime.new('0830', :pm)
      end

      specify '0835 to before 0835pm is 0835' do
        expect(ZTime.new('0835').modify_such_that_is_before(ZTime.new('0835', :pm))).to eq ZTime.new('0835')
      end

      specify '1021 to before 1223am is 1021pm' do
        expect(ZTime.new('1021').modify_such_that_is_before(ZTime.new('1223', :am))).to eq ZTime.new('1021', :pm)
      end

      specify '12 to before 2am is 12am' do
        expect(ZTime.new('12').modify_such_that_is_before(ZTime.new('2', :am))).to eq ZTime.new('12', :am)
      end

      specify '1220 to before 2am is 1220am' do
        expect(ZTime.new('1220').modify_such_that_is_before(ZTime.new('2', :am))).to eq ZTime.new('1220', :am)
      end

      specify '1220 to before 12am is 1220' do
        expect(ZTime.new('1220').modify_such_that_is_before(ZTime.new('12', :am))).to eq ZTime.new('1220')
      end

      specify '1220 to before 1220am is 1220' do
        expect(ZTime.new('1220').modify_such_that_is_before(ZTime.new('1220', :am))).to eq ZTime.new('1220')
      end

      specify '0930 to before 5pm is 0930' do
        expect(ZTime.new('0930').modify_such_that_is_before(ZTime.new('5', :pm))).to eq ZTime.new('0930')
      end

      specify '0930 to before 5am is 0930pm' do
        expect(ZTime.new('0930').modify_such_that_is_before(ZTime.new('5', :am))).to eq ZTime.new('0930', :pm)
      end

      specify '1100 to before 0425pm is 1100' do
        expect(ZTime.new('1100').modify_such_that_is_before(ZTime.new('0425', :pm))).to eq ZTime.new('1100')
      end

      specify '1100 to before 0425am is 1100pm' do
        expect(ZTime.new('1100').modify_such_that_is_before(ZTime.new('0425', :am))).to eq ZTime.new('1100', :pm)
      end

      specify '0115 to before 0120am is 0115' do
        expect(ZTime.new('0115').modify_such_that_is_before(ZTime.new('0120', :am))).to eq ZTime.new('0115')
      end

      specify '0115 to before 0120pm is 0115pm' do
        expect(ZTime.new('0115').modify_such_that_is_before(ZTime.new('0120', :pm))).to eq ZTime.new('0115', :pm)
      end

      specify '1020 to before 1015am is 1020pm' do
        expect(ZTime.new('1020').modify_such_that_is_before(ZTime.new('1015', :am))).to eq ZTime.new('1020', :pm)
      end

      specify '1020 to before 1015pm is 1020' do
        expect(ZTime.new('1020').modify_such_that_is_before(ZTime.new('1015', :pm))).to eq ZTime.new('1020')
      end

      specify '1015 to before 1020am is 1015' do
        expect(ZTime.new('1015').modify_such_that_is_before(ZTime.new('1020', :am))).to eq ZTime.new('1015')
      end

      specify '1015 to before 1020pm is 1015pm' do
        expect(ZTime.new('1015').modify_such_that_is_before(ZTime.new('1020', :pm))).to eq ZTime.new('1015', :pm)
      end
    end

    describe '#modify_such_that_is_after' do
      specify '1200 to after 1200am is 1200am' do
        expect(ZTime.new('1200').modify_such_that_is_after(ZTime.new('1200', :pm))).to eq ZTime.new('1200', :am)
      end

      specify '1200 to after 1200am is 1200' do
        expect(ZTime.new('1200').modify_such_that_is_after(ZTime.new('1200', :am))).to eq ZTime.new('1200')
      end

      specify '2 to after 1am is 2' do
        expect(ZTime.new('2').modify_such_that_is_after(ZTime.new('1', :am))).to eq ZTime.new('2')
      end

      specify '11 to after 10pm is 11pm' do
        expect(ZTime.new('11').modify_such_that_is_after(ZTime.new('10', :pm))).to eq ZTime.new('11', :pm)
      end

      specify '12 to after 8am is 12' do
        expect(ZTime.new('12').modify_such_that_is_after(ZTime.new('8', :am))).to eq ZTime.new('12')
      end

      specify '0835 to after 0830am is 0835' do
        expect(ZTime.new('0835').modify_such_that_is_after(ZTime.new('0830', :am))).to eq ZTime.new('0835')
      end

      specify '0835 to after 0830pm is 0835pm' do
        expect(ZTime.new('0835').modify_such_that_is_after(ZTime.new('0830', :pm))).to eq ZTime.new('0835', :pm)
      end

      specify '0835 to after 0835am is 0835pm' do
        expect(ZTime.new('0835').modify_such_that_is_after(ZTime.new('0835', :am))).to eq ZTime.new('0835', :pm)
      end

      specify '0835 to after 0835pm is 0835' do
        expect(ZTime.new('0835').modify_such_that_is_after(ZTime.new('0835', :pm))).to eq ZTime.new('0835')
      end

      specify '1223 to after 1021pm is 1223am' do
        expect(ZTime.new('1223').modify_such_that_is_after(ZTime.new('1021', :pm))).to eq ZTime.new('1223', :am)
      end

      specify '2 to after 12am is 2' do
        expect(ZTime.new('2').modify_such_that_is_after(ZTime.new('12', :am))).to eq ZTime.new('2')
      end

      specify '2 to after 1220am is 2' do
        expect(ZTime.new('2').modify_such_that_is_after(ZTime.new('1220', :am))).to eq ZTime.new('2')
      end

      specify '12 to after 1220am is 12' do
        expect(ZTime.new('12').modify_such_that_is_after(ZTime.new('1220', :am))).to eq ZTime.new('12')
      end

      specify '1220 to after 1220pm is 1220am' do
        expect(ZTime.new('1220').modify_such_that_is_after(ZTime.new('1220', :pm))).to eq ZTime.new('1220', :am)
      end

      specify '5 to after 0930am is 5pm' do
        expect(ZTime.new('5').modify_such_that_is_after(ZTime.new('0930', :am))).to eq ZTime.new('5', :pm)
      end

      specify '5 to after 0930pm is 5' do
        expect(ZTime.new('5').modify_such_that_is_after(ZTime.new('0930', :pm))).to eq ZTime.new('5')
      end

      specify '0425 to after 1100am is 0425pm' do
        expect(ZTime.new('0425').modify_such_that_is_after(ZTime.new('1100', :am))).to eq ZTime.new('0425', :pm)
      end

      specify '0425 to after 1100pm is 0425' do
        expect(ZTime.new('0425').modify_such_that_is_after(ZTime.new('1100', :pm))).to eq ZTime.new('0425')
      end

      specify '0120 to after 0115am is 0120' do
        expect(ZTime.new('0120').modify_such_that_is_after(ZTime.new('0115', :am))).to eq ZTime.new('0120')
      end

      specify '0120 to after 0115pm is 0120pm' do
        expect(ZTime.new('0120').modify_such_that_is_after(ZTime.new('0115', :pm))).to eq ZTime.new('0120', :pm)
      end

      specify '1015 to after 1020pm is 1015' do
        expect(ZTime.new('1015').modify_such_that_is_after(ZTime.new('1020', :pm))).to eq ZTime.new('1015')
      end

      specify '1015 to after 1020am is 1015pm' do
        expect(ZTime.new('1015').modify_such_that_is_after(ZTime.new('1020', :am))).to eq ZTime.new('1015', :pm)
      end

      specify '1020 to after 1015pm is 1020pm' do
        expect(ZTime.new('1020').modify_such_that_is_after(ZTime.new('1015', :pm))).to eq ZTime.new('1020', :pm)
      end

      specify '1020 to after 1015am is 1020' do
        expect(ZTime.new('1020').modify_such_that_is_after(ZTime.new('1015', :am))).to eq ZTime.new('1020')
      end
    end

    describe '#am_pm_modifier' do

      context 'passed one ztime' do
        it 'sets am/pm if not set' do
          t = ZTime.new('7', :pm)
          ZTime.am_pm_modifier(t)
          expect(t).to eq ZTime.new('7', :pm)
        end
      end

      context 'passed two ztimes' do
        it 'sets am/pm if not set' do
          tz = [ZTime.new('7', :pm), ZTime.new('8')]
          ZTime.am_pm_modifier(*tz)
          expect(tz).to eq [ZTime.new('7', :pm), ZTime.new('8', :pm)]
        end
      end

      context 'passed three ztimes' do
        it 'sets am/pm if not set' do
          tz = [ZTime.new('7', :pm), ZTime.new('8', :pm), ZTime.new('9')]
          ZTime.am_pm_modifier(*tz)
          expect(tz).to eq [ZTime.new('7', :pm), ZTime.new('8', :pm), ZTime.new('9', :pm)]
        end
      end

      context 'passed five ztimes' do
        it 'sets am/pm if not set' do
          tz = [ZTime.new('7'), ZTime.new('8', :am), ZTime.new('9'), ZTime.new('4', :pm), ZTime.new('7')]
          ZTime.am_pm_modifier(*tz)
          expect(tz).to eq [ZTime.new('7', :am), ZTime.new('8', :am), ZTime.new('9', :am), ZTime.new('4', :pm), ZTime.new('7', :pm)]
        end
      end
    end

    describe '#to_time' do
      it 'converts to a Time on todays date' do
        expect(ZTime.new('161718').to_time).to eq Time.parse('16:17:18')
      end
    end

    describe '#==' do
      let(:t1) { ZTime.new('161718') }

      it 'is true when the other ZTime is for the very same time of day' do
        expect(t1).to eq ZTime.new('161718')
      end

      it 'is false when the other ZTime is for any other time' do
        expect(t1).to_not eq ZTime.new('171819')
      end

      it 'is true when the other object is a Time for the same time of day' do
        expect(t1).to eq Time.parse('16:17:18')
      end

      it 'is false when the other object is a Time for any other time' do
        expect(t1).to_not eq Time.parse('17:18:19')
      end

      it 'is false when the other object is a String' do
        expect(t1).to_not eq '161718'
      end
    end

    describe '#hour_str' do
      it 'is the hour in the day as a string' do
        expect(ZTime.new('161718').hour_str).to eq('16')
      end
    end

    describe '#min_str' do
      it 'is the minutes past the hour as a string' do
        expect(ZTime.new('161718').min_str).to eq('17')
      end
    end

    describe '#sec_str' do
      it 'is the seconds into the minute as a string' do
        expect(ZTime.new('161718').sec_str).to eq('18')
      end
    end

    describe '#minute_str', :deprecated do
      it 'is the minutes past the hour as a string' do
        expect(ZTime.new('161718').min_str).to eq('17')
      end
    end

    describe '#second_str', :deprecated do
      it 'is the seconds into the minute as a string' do
        expect(ZTime.new('161718').sec_str).to eq('18')
      end
    end

    describe '#hour' do
      it 'is the hour in the day' do
        expect(ZTime.new('161718').hour).to eq(16)
      end
    end

    describe '#min' do
      it 'is the minutes past the hour' do
        expect(ZTime.new('161718').min).to eq(17)
      end
    end

    describe '#sec' do
      it 'is the seconds into the minute' do
        expect(ZTime.new('161718').sec).to eq(18)
      end
    end

    describe '#minute', :deprecated do
      it 'is the minutes past the hour' do
        expect(ZTime.new('161718').min).to eq(17)
      end
    end

    describe '#second', :deprecated do
      it 'is the seconds into the minute' do
        expect(ZTime.new('161718').sec).to eq(18)
      end
    end
  end
end
