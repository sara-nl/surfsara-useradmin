class ApplicationController < ActionController::Base
  include Trailblazer::Operation::Controller

  NotAuthenticated = Class.new(StandardError)

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :stub_shibboleth, if: -> { Rails.env.development? }
  before_action :authenticate
  before_action :expose_current_user

  rescue_from NotAuthenticated, with: :not_authenticated
  rescue_from Trailblazer::NotAuthorizedError, with: :not_authorized

  attr_accessor :current_user
  helper_method :current_user
  def current_user
    CurrentUser.from_request(request)
  end

  # :nocov:
  def stub_shibboleth
    if remote_user.blank?
      request.set_header('REMOTE_USER', 'isaac@university-example.org')
      request.set_header('Shib-uid', 'isaac')
      request.set_header('Shib-commonName', 'Sir Isaac Newton')
      request.set_header('Shib-homeOrganization', 'university-example.org')
      request.set_header('Shib-eduPersonEntitlement', 'urn:x-surfnet:surfsara.nl:opennebula:admin')
    end
  end
  # :nocov:

  def authenticate
    raise NotAuthenticated if remote_user.blank?
  end

  def remote_user
    request.headers['REMOTE_USER'] || request.headers['HTTP_REMOTE_USER']
  end

  def expose_current_user
    params[:current_user] = current_user
  end

  def not_authenticated
    render 'shared/not_authenticated', status: 401, layout: false
  end

  def not_authorized
    render 'shared/not_authorized', status: 403
  end

  def hide_menu
    @hide_menu = true
  end
end
