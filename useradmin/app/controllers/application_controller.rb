class ApplicationController < ActionController::Base
  include Trailblazer::Operation::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :mock_shibboleth, if: -> { Rails.env.development? || Rails.env.test? }

  attr_accessor :current_user
  helper_method :current_user
  def current_user
    CurrentUser.new(request)
  end

  def mock_shibboleth
    unless request.headers.include?('REMOTE_USER') || request.headers.include?('HTTP_REMOTE_USER')
      request.set_header('REMOTE_USER', 'admin')
      request.set_header('Shib-commonName', 'John Doe')
    end
  end

  CurrentUser = Struct.new(:request) do
    def uid
      request.get_header('REMOTE_USER') || request.get_header('HTTP_REMOTE_USER')
    end

    def common_name
      request.get_header('Shib-commonName')
    end

    def role
      return 'admin' if uid.in? %w(admin isaac)
      return 'groupadmin' if uid == 'groupadmin123'
    end

    def shibboleth_headers
      Hash[request.headers.select { |k, _| k.starts_with?('Shib-') }]
    end

    def admin?
      role == 'admin'
    end

    def groupadmin?
      role == 'groupadmin'
    end
  end
end
