# Add spec/support to load path so `require 'js'` in the library resolves to our stub
$LOAD_PATH.unshift(File.join(__dir__, 'support'))

require 'js'

module PicoDX
end

Dir[File.join(__dir__, '../lib/picodx/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.before { JS.reset! }
end
