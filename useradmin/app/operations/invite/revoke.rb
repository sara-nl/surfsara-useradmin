class Invite < ApplicationRecord
  class Revoke < Operation
    include Model
    model Invite, :find

    def process(_)
      model.update!(revoked_at: Time.current, revoked_by: current_user.one_username)
    end

    private

    def model!(params)
      Invite.scoped_to(current_user).pending.find(params[:id])
    end
  end
end
