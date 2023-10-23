# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# Disable warnings locally
$VERBOSE = ENV["CI"]
require "openssl"
require "base64"

ENV["LAGO_API_URL"] = "http://localhost:3000"

require "rails/test_help"
require "byebug"
require "minitest/mock"
require "mocha/minitest"
require "receipts"

require File.expand_path("dummy/config/environment.rb", __dir__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("dummy/db/migrate", __dir__), File.expand_path("../db/migrate", __dir__)]

require_relative "support/vcr"

# Uncomment to view the stacktrace for debugging tests
Rails.backtrace_cleaner.remove_silencers!

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths << File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_paths << File.expand_path("../fixtures", __FILE__)
elsif ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
end

ActiveSupport::TestCase.fixtures :all

class ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def fake_event(name, format: :json)
    JSON.parse File.read("test/support/fixtures/#{name}.#{format}")
  end

  def travel_to_cassette
    travel_to(VCR.current_cassette.originally_recorded_at || Time.current) do
      yield
    end
  end

  def assert_indexed_selects
    subscriber = ActiveSupport::Notifications.subscribe "sql.active_record" do |name, started, finished, unique_id, data|
      if data[:sql].starts_with? "SELECT"
        result = data[:connection].explain(data[:sql], data[:binds]).downcase
        assert result.include?("index"), "Query `#{data[:name]}` did not use an index!"
      end
    end

    yield
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
