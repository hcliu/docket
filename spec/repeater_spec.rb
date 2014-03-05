require 'spec_helper'

describe Docket::Repeater do

  describe '#set' do

    it "sets the schedule" do
      scheduler_action = lambda { |repeater, frequency| 
        repeater.scheduler.every(frequency, :times => 1) { @thing = "hello" } }

      repeater = Docket::Repeater.new(\
        :frequencies            => ['1s'], 
        :scheduler_action       => scheduler_action,
        :scheduler_set_callback => lambda { |scheduler| },
        :storage                => $storage)  

      repeater.set
      sleep(1.5)
      repeater.stop

      expect(@thing).to eql('hello')
    end

    context 'with round robin' do

      let(:round_robin) { Docket::RoundRobin.new(:storage => $storage) }

      before :each do
        $storage.send(:clear!)
      end

      it "runs a round robin schedule on time" do
        @trained = Array.new

        round_robin.set("trainer_15", ['dog', 'lion', 'tiger'], :group => '1s')
        round_robin.set("trainer_16", ['frog', 'lizard', 'snake'], :group => '2s')
        round_robin.set("trainer_17", ['panda', 'brown', 'black'], :group => '3s')

        scheduler_action = lambda do |repeater, frequency|
          repeater.scheduler.every(frequency, :times => 1) do
            repeater.items_for(frequency).each do |key| 
              repeater.perform_on.perform(key, lambda { |robin| @trained << robin }) 
            end
          end
        end

        repeater = Docket::Repeater.new(\
          :frequencies            => ['1s', '2s', '3s'],
          :storage                => $storage,
          :perform_on             => round_robin,
          :scheduler_action       => scheduler_action,
          :repeat                 => 1
        )

        repeater.set
        sleep(3.5)
        repeater.stop

        expect(@trained.size).to eql(3)
        expect(@trained).to include('lion', 'lizard', 'brown')
      end
    end

    describe '#repeated_items' do
      let(:round_robin) { Docket::RoundRobin.new(:storage => $storage) }

      before :each do
        $storage.send(:clear!)
      end

      it "lists items that are on repeat" do

        action = lambda { |robin| @animal_to_train = robin }
        round_robin.set("trainer_15", ['dog', 'lion', 'tiger'], :group => '1w')
        round_robin.set("trainer_16", ['dog', 'lion', 'tiger'], :group => '5m')
        round_robin.set("trainer_17", ['dog', 'lion', 'tiger'], :group => '1m')

        scheduler_action = lambda do |scheduler, frequency| 
          scheduler.every(frequency, :times => 1) {  }
        end

        repeater = Docket::Repeater.new(\
          :frequencies            => ['1w', '5m', '1m'], 
          :scheduler_action       => scheduler_action,
          :scheduler_set_callback => lambda { |scheduler| },
          :storage                => $storage,
          :perform_on             => round_robin
        )

        expect(repeater.repeated_items.size).to eql(3)
      end
    end

  end

end
