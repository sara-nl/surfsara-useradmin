class ApplicationController < ActionController::Base
  include Trailblazer::Operation::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  attr_accessor :current_user
  helper_method :current_user
  def current_user
    CurrentUser.new(request.headers['REMOTE_USER'])
    # CurrentUser.new('admin123')
    # CurrentUser.new('otheruser123')
  end

  CurrentUser = Struct.new(:user_id) do
    def name
      user_id
    end

    def role
      return 'admin' if user_id == 'admin'
      return 'groupadmin' if user_id == 'groupadmin123'
    end

    def admin?
      role == 'admin'
    end

    def groupadmin?
      role == 'groupadmin'
    end
  end
end
