module Docket
  class RoundRobin

    attr_accessor :storage

    def initialize args={}
      @storage = args[:storage] || Docket.configuration.storage || Docket::Storage::Daybreak.new('/tmp/docket.rb')
    end

    def set identifier, robins, options={}
      save identifier, robins, options
    end

    def perform identifier, action
      robin = next_robin identifier
      action.call(robin)
      robin
    end

    def unset identifier
      unset_key identifier
      unset_from_groups identifier
    end

    def reset!
      storage.clear!
    end
  
    protected

    def unset_key identifier
      storage.remove identifier
    end

    def unset_from_groups identifier
      groups = storage.read("#{identifier}_groups")
      Array(groups).each do |group|
        old_group = storage.read(group)
        storage.save(group, old_group.reject { |item| item == identifier })
      end

      storage.remove "#{identifier}_groups"
    end

    def next_robin identifier
      list = storage.read(identifier) || []
      robin_list = RobinList.new(list)

      next_robin = robin_list.fetch_next
      save identifier, nil, :list => robin_list.list

      next_robin
    end

    def save identifier, robins, options={}
      list = options[:list] || robins

      storage.save(identifier, list)
      storage.append(options[:group], identifier) if options[:group]
      storage.append("#{identifier}_groups", options[:group]) if options[:group]
    end

  end
end
