class Invite < ApplicationRecord
  class Show < Operation
    include Trailblazer::Operation::Policy

    policy Invite::Policy, :show?

    def model!(params)
      Invite
        .scoped_to(current_user)
        .find(params[:id])
    end
  end
end
