require 'digest/sha1'

class Invite < ApplicationRecord
  class Index < Operation
    include Collection

    def model!(params)
      return invites if current_user.admin?
      return group_invites if current_user.groupadmin?
      invites.none
    end

    private

    def invites
      Invite.order(created_at: :desc)
    end

    def group_invites
      invites
    end

    def current_user
      @params[:current_user]
    end
  end
end
