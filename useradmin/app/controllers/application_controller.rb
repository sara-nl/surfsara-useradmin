class ApplicationController < ActionController::Base
  include Trailblazer::Operation::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :mock_shibboleth, if: -> { Rails.env.development? || Rails.env.test? }
  before_action :expose_current_user

  attr_accessor :current_user
  helper_method :current_user
  def current_user
    CurrentUser.new(request)
  end

  # rubocop:disable AbcSize
  def mock_shibboleth
    unless request.headers.include?('REMOTE_USER') || request.headers.include?('HTTP_REMOTE_USER')
      request.set_header('REMOTE_USER', 'isaac@university-example.org')
      request.set_header('Shib-uid', 'isaac')
      request.set_header('Shib-commonName', 'Sir Isaac Newton')
      request.set_header('Shib-homeOrganization', 'university-example.org')
      request.set_header('Shib-eduPersonEntitlement', 'urn:x-surfnet:surfsara.nl:opennebula:admin')
      request.set_header('Shib-eduPersonPrincipalName', 'isaac@university-example.org')
    end
  end
  # rubocop:enable AbcSize

  def expose_current_user
    params[:current_user] = current_user
  end
end
