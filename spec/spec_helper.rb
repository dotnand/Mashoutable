require 'rubygems'
require 'spork'
require 'hashie'
require 'httparty'
require 'capybara/rails'
require 'capybara/poltergeist'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include Rails.application.routes.url_helpers

    Rails.application.routes.default_url_options = { :host => 'localhost:3000' }
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, :debug => true)
    end

    Capybara.javascript_driver = :poltergeist
    Capybara.server_port = '1337' # Port number not important, just needs to have some value
  end
end

Spork.each_run do
  require "factories"
  # This code will be run each time you run your specs.
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading
#   code that you don't normally modify during development in the
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#

