class Invite < ApplicationRecord
  class Accept < Operation
    include Model
    model Invite, :find

    contract do
      property :accept_terms_of_service, virtual: true

      validate :accept_terms_of_service do
        errors.add(:accept_terms_of_service, :not_accepted) if accept_terms_of_service != '1'
      end
    end

    def process(params)
      return invalid! if @model.nil?

      validate(params[:invite]) do
        update_open_nebula
        update_invite
      end
    end

    private

    def model!(params)
      invite_token = InviteToken.new(params[:id])
      Invite.pending.find_by(token: invite_token.encrypted)
    end

    def update_open_nebula
      One::CreateUser.(current_user: current_user, invite: @model)
    end

    def update_invite
      @model.update!(accepted_at: Time.current, accepted_by: current_user.one_username)
    end

    def current_user
      @params[:current_user]
    end
  end
end
