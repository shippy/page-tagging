# spec/spec_helper.rb
ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'

require File.expand_path '../../app.rb', __FILE__

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

module RSpecMixin
  include Rack::Test::Methods
  def app() PageTagger end
end

# For RSpec 2.x
RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
  config.include Rack::Test::Methods
  config.include RSpecMixin
end
# If you use RSpec 1.x you should use this instead:
# Spec::Runner.configure { |c| c.include RSpecMixin }