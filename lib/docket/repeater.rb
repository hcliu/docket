require 'rufus-scheduler'

module Docket
  class Repeater

    attr_accessor :frequencies, :perform_action, :perform_on, 
                  :scheduler, :scheduler_action, :scheduler_set_callback
    attr_reader :storage, :repeat

    def initialize args={}
      @frequencies            = args[:frequencies]
      @perform_action         = args[:perform_action]
      @perform_on             = args[:perform_on]
      @scheduler              = args[:scheduler] || Rufus::Scheduler.new
      @scheduler_action       = args[:scheduler_action]
      @scheduler_set_callback = args[:scheduler_set_callback] || lambda {|scheduler|}
      @storage                = args[:storage] || Docket.configuration.storage || Docket::Storage::Daybreak.new('/tmp/docket.rb')
      @repeat                 = args[:repeat]
    end

    def repeated_items
      frequencies.collect { |frequency| items_for frequency }.compact.flatten
    end

    def items_for frequency
      Array(storage.read(frequency))
    end

    def set
      frequencies.each do |frequency|
        if scheduler_action
          scheduler_action.call(self, frequency)
        else
          scheduler.every(frequency, :times => repeat) do
            items_for(frequency).each { |key| perform_on.perform(key, perform_action) }
          end
        end

      end

      scheduler_set_callback.call(scheduler)
    end

    def stop force=false
      if force
        scheduler.shutdown(:kill)
      else
        scheduler.shutdown(:wait)
      end
    end

  end
end
