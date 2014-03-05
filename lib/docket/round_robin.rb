module Docket
  class RoundRobin

    attr_accessor :storage

    def initialize args={}
      @storage = args[:storage] || Docket::Storage.new('/tmp/docket.rb')
    end

    def set identifier, robins, options={}
      _set identifier, robins, options
    end

    def perform identifier, action
      robin = _next_robin identifier
      action.call(robin)
    end
  
    protected

    def _next_robin identifier
      list = storage.read(identifier) || []
      robin_list = RobinList.new(list)

      next_robin = robin_list.fetch_next
      _set identifier, nil, :list => robin_list.list

      next_robin
    end

    def _set identifier, robins, options={}
      list = options[:list] || robins

      storage.save(identifier, list, options)
    end

  end
end
