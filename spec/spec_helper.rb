require 'docket'
require 'pry'
require 'fakeredis'

$storage = Docket::Storage::Daybreak.new('/tmp/docket_spec.rb')
RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = 'documentation'
  config.order = 'random'

  config.before(:suite) do
    $storage.send(:clear!)
  end

  config.after(:suite) do
    $storage.close
  end

end

def reload_storage_connection
  if $storage && !$storage.closed?
    $storage.close
    $storage = Docket::Storage::Daybreak.new('/tmp/docket_spec.rb')
  end
end
