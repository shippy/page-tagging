require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'capybara'
require 'factory_girl'
require 'faker'

require_relative './factories.rb'

require File.expand_path '../../app.rb', __FILE__

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

# Suppress forced db-query to stdout in between RSpec test results
ActiveRecord::Base.logger.level = 2

module RSpecMixin
  include Rack::Test::Methods
  def app() PageTagger end
end

Capybara.app = PageTagger
Capybara.default_driver = :rack_test # mark JS tests with :js => true or @javascript

# For RSpec 2.x
RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation
  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods
  config.include Capybara::DSL
  config.include RSpecMixin
end