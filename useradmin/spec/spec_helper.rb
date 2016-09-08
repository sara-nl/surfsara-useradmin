require 'rspec/its'
require 'webmock/rspec'
require 'vcr'
require 'simplecov'

SimpleCov.add_filter 'vendor'
SimpleCov.add_filter 'config'
SimpleCov.add_filter 'lib/tasks'
SimpleCov.add_filter 'spec'
SimpleCov.start

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.around(:each, :integration) do |example|
    VCR.use_cassette(example.metadata[:full_description]) do
      example.run
    end
  end
end
