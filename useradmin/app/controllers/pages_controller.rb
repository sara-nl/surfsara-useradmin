class PagesController < ApplicationController
  skip_before_action :stub_shibboleth, :authenticate, :expose_current_user, only: :splash

  def index
  end

  def splash
    hide_menu
  end
end
