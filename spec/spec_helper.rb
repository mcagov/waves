require "simplecov"
require "webmock/rspec"
require "rack_session_access/capybara"
require "email_spec"
require "email_spec/rspec"

SimpleCov.start

# http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.order = :random

  config.around(:each) do |example|
    stub_request(:get, "https://www.gov.uk/bank-holidays.json")
      .with(headers: { "Accept" => "*/*", "User-Agent" => "Ruby" })
      .to_return(
        body: File.read("#{Rails.root}/spec/fixtures/govuk_holidays.json"))

    WebMock.disable_net_connect!(allow_localhost: true)

    example.call

    WebMock.allow_net_connect!
  end

  config.after(:suite) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
