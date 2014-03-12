require 'spec_helper'

describe Docket::RoundRobin do

  let(:round_robin) { Docket::RoundRobin.new(:storage => $storage) }

  describe '#set' do
    it 'sets a list of robins for some identifier key' do
      round_robin.set("trainer_15", ['dog', 'lion', 'tiger'])
      expect($storage.db.get('trainer_15')).to be_kind_of(Array)
    end
  end

  describe '#perform' do
    it "takes the next robin and calls action with it" do
      action = lambda { |robin| @animal_to_train = robin }
      round_robin.set("trainer_15", ['dog', 'lion', 'tiger'])

      round_robin.perform("trainer_15", action)
      expect(@animal_to_train).to eql('lion')

      round_robin.perform("trainer_15", action)
      expect(@animal_to_train).to eql('tiger')

      round_robin.perform("trainer_15", action)
      expect(@animal_to_train).to eql('dog')

      round_robin.perform("trainer_15", action)
      expect(@animal_to_train).to eql('lion')
    end

    it "persists accross sessions" do
      action = lambda { |robin| @animal_to_train = robin }

      round_robin.set("trainer_15", ['dog', 'lion', 'tiger'])
      round_robin.perform("trainer_15", action)

      reload_storage_connection
      
      round_robin = Docket::RoundRobin.new(:storage => $storage)

      round_robin.perform("trainer_15", action)
      expect(@animal_to_train).to eql('tiger')
    end

    it "works with arrays of arrays" do
      action = lambda { |robin| @robins = robin }

      round_robin.set("trainer_15", [['dog', 'lion', 'tiger'], ['cages', 'sidewalks', 'bathrooms']])

      round_robin.perform("trainer_15", action)
      expect(@robins).to eql(['cages', 'sidewalks', 'bathrooms'])
      round_robin.perform("trainer_15", action)
      expect(@robins).to eql(['dog', 'lion', 'tiger'])

      round_robin.set("trainer_16", [['kids', 'adults']])
      round_robin.perform("trainer_16", action)
      expect(@robins).to eql(['kids', 'adults'])
      round_robin.perform("trainer_16", action)
      expect(@robins).to eql(['kids', 'adults'])
    end
  end

end
