require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
abort('The Rails environment is running in production mode!') if Rails.env.production?
ActiveRecord::Migration.maintain_test_schema!

unless defined?(TESTS_ARE_LOADED)
  # silence_warnings { BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST }
  require 'rails/all'
  require 'rspec/rails'
  require 'rspec/expectations'
  require 'shoulda/matchers'
  require 'capybara/rails'
  require 'capybara/rspec'
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Database Cleaner

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Chrome Driver
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  def hipster_ipsum
    Faker::Hipster.sentence(4, false, 4)
  end
end


# Remove uploaded panoramas after request
RSpec.configure do |config|
  config.after(:each) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
  end
end

# Set Warden config
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ValidUserRequestHelper, :type => :request
end

#Tell factory bot where the defs are
FactoryBot.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryBot.find_definitions
