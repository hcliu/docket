module Docket
  class Configuration
    attr_accessor :storage, :storage_namespace

    def initialize
      @storage_namespace = 'docket'
      @storage = nil
    end
  end

  attr_accessor :configuration

  extend self
  
  def configuration
    @configuration ||= Configuration.new    
  end

  def configure
    yield(configuration)
  end

end
