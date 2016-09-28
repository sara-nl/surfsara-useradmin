class Invite < ApplicationRecord
  class Index < Operation
    include Collection
    include Trailblazer::Operation::Policy

    policy Invite::Policy, :index?

    def model!(params)
      Invite
        .scoped_to(current_user)
        .order(created_at: :desc)
        .page(params[:page])
    end
  end
end
