require 'rails_helper'
require 'capybara/rspec'
require 'capybara/webkit'
require 'capybara-screenshot/rspec'

Capybara.default_max_wait_time = 5
Capybara.javascript_driver = :webkit
Capybara.save_path = 'tmp/capybara'
Capybara::Screenshot.webkit_options = {width: 1280, height: 960}
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara::Webkit.configure do |config|
  config.allow_url("netdna.bootstrapcdn.com")
end

RSpec.configure do |config|
  config.before(:each, :feature) do
    page.driver.header 'REMOTE_USER', 'admin'
  end
end
