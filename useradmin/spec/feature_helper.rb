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

RSpec.configure do |c|
  c.use_transactional_fixtures = false

  c.before do |example|
    trait = example.metadata[:current_user]
    unless trait == :logged_out
      user =
        if trait.present?
          build(:current_user, trait)
        else
          build(:current_user)
        end

      to_shib_headers(user).each do |k, v|
        Capybara.current_session.driver.header(k, v)
      end
    end
  end

  def to_shib_headers(user)
    {
      'REMOTE_USER' => user.remote_user,
      'Shib-uid' => user.uid,
      'Shib-commonName' => user.common_name,
      'Shib-homeOrganization' => user.home_organization,
      'Shib-eduPersonEntitlement' => user.edu_person_entitlement,
    }
  end
end
