class Invite < ApplicationRecord
  class Accepted < Operation
    include Trailblazer::Operation::Policy

    policy Invite::Policy, :accepted?

    def model!(params)
      invite_token = InviteToken.new(params[:id])
      Invite.find_by!(accepted_by: current_user.remote_user, token: invite_token.hashed)
    end
  end
end
