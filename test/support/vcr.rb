require "vcr"

unless ENV["SKIP_VCR"]
  require "webmock/minitest"

  VCR.configure do |c|
    c.cassette_library_dir = "test/vcr_cassettes"
    c.hook_into :webmock
    c.allow_http_connections_when_no_cassette = true
    c.filter_sensitive_data("<LAGO_API_KEY>") { Pay::Lago.api_key }
  end

  class ActiveSupport::TestCase
    setup do
      # Test filenames are case sensitive in CI
      VCR.insert_cassette name, allow_unused_http_interactions: false, record_on_error: false
    end

    teardown do
      cassette = VCR.current_cassette
      VCR.eject_cassette
    rescue VCR::Errors::UnusedHTTPInteractionError
      puts
      puts "Unused HTTP requests in cassette: #{cassette.file}"
      raise
    end
  end
end
