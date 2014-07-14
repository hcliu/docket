require 'spec_helper'

describe Docket::RoundRobin do

  before(:all) do
    @storage = Docket::Storage::Redis.new
    Docket.configure do |config|
      config.storage = @storage
    end
  end

  let(:round_robin) { Docket::RoundRobin.new }

  describe '#set' do

    before :all do
      @storage.clear!
    end

    it 'sets a list of robins for some identifier key' do
      round_robin.set("trainer_15", ['dog', 'lion', 'tiger'])
      expect(@storage.read('trainer_15')).to be_kind_of(Array)
    end

    context "using group" do
      before :each do
        round_robin.set("trainer_15", ['dog', 'lion', 'tiger'], :group => 'group1')
        reload_storage_connection
      end
      
      it "writes to the group list" do
        expect(@storage.read("group1")).to eql(['trainer_15'])
      end

      it "creates its own index of groups" do
        expect(@storage.read("trainer_15_groups")).to eql(['group1'])
      end
    end
  end

  describe '#unset' do

    before :each do
      @storage.clear!
      round_robin.set("trainer_15", ['dog', 'lion', 'tiger'], :group => "daily")
      round_robin.set("trainer_16", ['cat', 'mouse', 'cheese'], :group => "daily")
      round_robin.unset("trainer_15")
    end

    it "removes the list of groups associated" do
      expect(@storage.read('daily')).to_not include("trainer_15")
      expect(@storage.read('daily')).to include("trainer_16")
    end

    it "removes index of groups" do
      expect(@storage.read("trainer_15_groups")).to be_nil
    end

    it "removes the identifier" do
      expect(@storage.read("trainer_15")).to be_nil
    end

    context 'when key not set' do
      it 'does not raise an error' do
        round_robin.unset("trainer_not_exists")
      end
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
      
      round_robin = Docket::RoundRobin.new(:storage => @storage)

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
