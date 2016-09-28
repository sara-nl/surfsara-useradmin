class Invite < ApplicationRecord
  class Revoke < Operation
    include Model
    include Trailblazer::Operation::Policy

    model Invite, :find
    policy Invite::Policy, :revoke?

    def process(_)
      model.update!(revoked_at: Time.current, revoked_by: current_user.edu_person_principal_name)
    end

    private

    def model!(params)
      Invite.scoped_to(current_user).pending.find(params[:id])
    end
  end
end
