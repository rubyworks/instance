require 'spec_helper'

class Song
  attr_accessor :title
  attr_accessor :artist
  attr_accessor :year

  def initialize(title, artist, year)
    @title  = title
    @artist = artist
    @year   = year
  end
end

describe MetaInstance do

  let(:song){ Song.new("Paranoid", "Black Sabbath", 1970) }

  describe '#variables' do

    it 'returns instance variables as an array of symbols' do
      actual = song.instance.variables
      expected = [:@title, :@artist, :@year]
      expect(actual).to eq expected
    end

  end

  describe '#get' do
    it 'gets the instance variable' do
      actual = song.instance.get(:title)
      expect(actual).to eq 'Paranoid'
    end
  end

  describe '#set' do
    it 'sets the instance varibale' do
      expected = song.instance.get(:title) + '!!!'
      song.instance.set(:title, expected)
      actual = song.instance.get(:title)

      expect(actual).to eq expected
    end
  end

  describe '#[]' do
    it 'retrieves an instance variable' do
      actual = song.instance[:title]
      expect(actual).to eq 'Paranoid'
    end
  end

  describe '#to_h' do
    it 'converts the list of instance variables to a hash' do
      actual = song.instance.to_h
      expected = {:title => "Paranoid", :artist => "Black Sabbath", :year => 1970}

      expect(actual).to eq expected
    end

    it 'converts the list of instance variables to a hash with @ in the keys'  do
      actual = song.instance.to_h(true)
      expected = {:@title => "Paranoid", :@artist => "Black Sabbath", :@year => 1970}

      expect(actual).to eq expected
    end
  end

  describe '#size' do
    it 'counts the number of instance variables' do
      actual = song.instance.size
      expect(actual).to eq 3
    end
  end

  describe '#<<' do
    it 'sets an instance variable' do
      song.instance << [:something, :else]
      actual = song.instance.get(:something)

      expect(actual).to eq :else
    end
  end

  describe '#remove' do
    it 'removes an instance variable' do
      song.instance.remove(:title)
      actual = song.instance.get(:title)

      expect(actual).to eq nil
    end
  end

  describe '#update' do
    it 'updates an instance variable' do
      song.instance.update(title: 'new title', other: 'var')
      actual = song.instance.get(:title)
      actual2 = song.instance.get(:other)

      expect(actual).to eq 'new title'
      expect(actual2).to eq 'var'
    end
  end

  describe '#names' do
    it 'returns the list of instance variables' do
      actual = song.instance.keys

      expect(actual).to eq [:title, :artist, :year]
    end
  end

  describe '#values' do
    it 'retrurns a list of values of the instance variables' do
      actual = song.instance.values
      expected = ["Paranoid", "Black Sabbath", 1970]

      expect(actual).to eq expected
    end
  end


end
