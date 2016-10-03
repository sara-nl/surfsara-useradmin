class PagesController < ApplicationController
  skip_before_action :stub_shibboleth, if: -> { Rails.env.development? }
  skip_before_action :authenticate
  skip_before_action :expose_current_user

  def splash
    hide_menu
  end
end
