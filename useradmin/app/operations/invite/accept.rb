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
      validate(params[:invite]) do
        @model.accepted_at = Time.current
        @model.accepted_by = @params[:current_user].uid
        @model.save
      end
    end

    private

    def model!(params)
      invite_token = InviteToken.new(params[:id])
      Invite.find_by!(accepted_at: nil, token: invite_token.encrypted)
    end
  end
end
