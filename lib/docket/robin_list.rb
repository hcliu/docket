# adapted from https://github.com/bangthetable/CircularList

module Docket
  class RobinList
    def initialize(array)
      @array = array
    end

    def size
      @array.size
    end

    def list
      @array
    end

    def fetch_previous(index=0)
      index.nil? ? nil : @array.unshift(@array.pop)[index]
    end

    def fetch_next(index=0)
      index.nil? ? nil : @array.push(@array.shift)[index]
    end
    
    def fetch_after(e)
      fetch_next(@array.index(e))
    end
    
    def fetch_before(e)
      fetch_previous(@array.index(e))
    end
  end
end
