# Add spec/support to load path so `require 'js'` in the library resolves to our stub
$LOAD_PATH.unshift(File.join(__dir__, 'support'))

require_relative '../lib/picoruby_wasm_template'

RSpec.configure do |config|
  config.before { JS.reset! }
end
