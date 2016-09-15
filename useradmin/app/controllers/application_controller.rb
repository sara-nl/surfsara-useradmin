class ApplicationController < ActionController::Base
  include Trailblazer::Operation::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  attr_accessor :current_user
  helper_method :current_user
  def current_user
    CurrentUser.new(request.headers)
  end

  CurrentUser = Struct.new(:headers) do
    def uid
      shibboleth_headers['Shib-uid']
    end

    def common_name
      shibboleth_headers['Shib-commonName']
    end

    def role
      return 'admin' if uid.in? %w(admin professor3)
      return 'groupadmin' if uid == 'groupadmin123'
    end

    def shibboleth_headers
      Hash[headers.select { |k, _| k.starts_with?('Shib-') }]
    end

    def admin?
      role == 'admin'
    end

    def groupadmin?
      role == 'groupadmin'
    end
  end
end
