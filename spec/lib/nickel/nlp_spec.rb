require "spec_helper"
require_relative "../../../lib/nickel/nlp"

describe Nickel::NLP do
  describe "#message" do
    it "extracts 'do something' from 'do something today'" do
      nlp = Nickel::NLP.new("do something today").tap(&:parse)
      expect(nlp.message).to eq "do something"
    end

    it "extracts 'there is a movie' from 'there is a movie today at noon'" do
      nlp = Nickel::NLP.new("there is a movie today at noon").tap(&:parse)
      expect(nlp.message).to eq "there is a movie"
    end

    it "extracts 'go to work' from 'go to work today and tomorrow'" do
      nlp = Nickel::NLP.new("go to work today and tomorrow").tap(&:parse)
      expect(nlp.message).to eq "go to work"
    end

    it "extracts 'appointments with the dentist' from 'appointments with the dentist are on oct 5 and oct 23rd'" do
      nlp = Nickel::NLP.new("appointments with the dentist are on oct 5 and oct 23rd").tap(&:parse)
      expect(nlp.message).to eq "appointments with the dentist"
    end

    it "extracts 'there will be an office meeting' from 'today at noon and tomorrow at 5:45 am there will be an office meeting'" do
      nlp = Nickel::NLP.new("Today at noon and tomorrow at 5:45 am there will be an office meeting").tap(&:parse)
      expect(nlp.message).to eq "there will be an office meeting"
    end

    it "extracts 'some stuff to do' from 'some stuff to do at noon today and 545am tomorrow'" do
      nlp = Nickel::NLP.new("some stuff to do at noon today and 545am tomorrow").tap(&:parse)
      expect(nlp.message).to eq "some stuff to do"
    end

    it "extracts 'go to the park with the dog' from 'go to the park tomorrow and thursday with the dog'" do
      nlp = Nickel::NLP.new("go to the park tomorrow and thursday with the dog").tap(&:parse)
      expect(nlp.message).to eq "go to the park with the dog"
    end

    it "extracts 'go to the park with the dog' from 'go to the park tomorrow and thursday with the dog'" do
      nlp = Nickel::NLP.new("go to the park tomorrow and thursday with the dog").tap(&:parse)
      expect(nlp.message).to eq "go to the park with the dog"
    end

    it "extracts 'how awesome is this?' from 'how awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this?'" do
      nlp = Nickel::NLP.new("how awesome tomorrow at 1am and from 2am to 5pm and thursday at 1pm is this?").tap(&:parse)
      expect(nlp.message).to eq "how awesome is this?"
    end

    it "extracts 'soccer practice with susan' from 'soccer practice monday tuesday and wednesday with susan'" do
      nlp = Nickel::NLP.new("soccer practice monday tuesday and wednesday with susan").tap(&:parse)
      expect(nlp.message).to eq "soccer practice with susan"
    end

    it "extracts 'I have guitar lessons' from 'monday and wednesday at 4pm I have guitar lessons'" do
      nlp = Nickel::NLP.new("monday and wednesday at 4pm I have guitar lessons").tap(&:parse)
      expect(nlp.message).to eq "I have guitar lessons"
    end

    it "extracts 'meet with so and so' from 'meet with so and so 4pm on monday and wednesday'" do
      nlp = Nickel::NLP.new("meet with so and so 4pm on monday and wednesday").tap(&:parse)
      expect(nlp.message).to eq "meet with so and so"
    end

    it "extracts 'flight on American' from 'flight this sunday on American'" do
      nlp = Nickel::NLP.new("flight this sunday on American").tap(&:parse)
      expect(nlp.message).to eq "flight on American"
    end

    it "extracts 'Flight to Miami on Jet Blue' from 'Flight to Miami this sunday 9-5am on Jet Blue'" do
      nlp = Nickel::NLP.new("Flight to Miami this sunday 9-5am on Jet Blue").tap(&:parse)
      expect(nlp.message).to eq "Flight to Miami on Jet Blue"
    end

    it "extracts 'Go to the park' from 'Go to the park this sunday 9-5'" do
      nlp = Nickel::NLP.new("Go to the park this sunday 9-5").tap(&:parse)
      expect(nlp.message).to eq "Go to the park"
    end

    it "extracts 'movie showings' from 'movie showings are today at 10, 11, 12, and 1 to 5'" do
      nlp = Nickel::NLP.new("movie showings are today at 10, 11, 12, and 1 to 5").tap(&:parse)
      expect(nlp.message).to eq "movie showings"
    end

    it "extracts 'Flight' from 'Flight is a week from today'" do
      nlp = Nickel::NLP.new("Flight is a week from today").tap(&:parse)
      expect(nlp.message).to eq "Flight"
    end

    it "extracts 'Bill is due' from 'Bill is due two weeks from tomorrow'" do
      nlp = Nickel::NLP.new("Bill is due two weeks from tomorrow").tap(&:parse)
      expect(nlp.message).to eq "Bill is due"
    end

    it "extracts 'Tryouts' from 'Tryouts are two months from now'" do
      nlp = Nickel::NLP.new("Tryouts are two months from now").tap(&:parse)
      expect(nlp.message).to eq "Tryouts"
    end

    it "extracts 'baseball game' from 'baseball game is on october second'" do
      nlp = Nickel::NLP.new("baseball game is on october second").tap(&:parse)
      expect(nlp.message).to eq "baseball game"
    end

    it "extracts 'something' from 'something for the next 1 day'" do
      nlp = Nickel::NLP.new("something for the next 1 day").tap(&:parse)
      expect(nlp.message).to eq "something"
    end

    it "extracts 'go to the park with the dog' from 'go to the park tomorrow and also on thursday with the dog'" do
      nlp = Nickel::NLP.new("go to the park tomorrow and also on thursday with the dog").tap(&:parse)
      expect(nlp.message).to eq "go to the park with the dog"
    end

    it "extracts 'pick up groceries and also the kids' from 'pick up groceries tomorrow and also the kids'" do
      nlp = Nickel::NLP.new("pick up groceries tomorrow and also the kids").tap(&:parse)
      expect(nlp.message).to eq "pick up groceries and also the kids"
    end

    it "extracts 'do something' from 'do something on january first'" do
      nlp = Nickel::NLP.new("do something on january first").tap(&:parse)
      expect(nlp.message).to eq "do something"
    end

    it "extracts 'go to the museum' from 'on the first of the month, go to the museum'" do
      nlp = Nickel::NLP.new("on the first of the month, go to the museum").tap(&:parse)
      expect(nlp.message).to eq "go to the museum"
    end
  end
end
