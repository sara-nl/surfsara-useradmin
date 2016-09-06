require 'digest/sha1'

class Invite < ActiveRecord::Base
  class Create < Operation
    contract do
      property :email, validates: { presence: true }
    end

    def process(params)
      @model = Invite.new(token: encrypted_token)

      validate(params[:invite], @model) do
        contract.save
        send_invitation!
      end
    end

    private

    def send_invitation!
      InviteMailer.invitation(@model.email, random_token).deliver_now
    end

    def encrypted_token
      Digest::SHA2.hexdigest(random_token)
    end

    def random_token
      @random_token ||= SecureRandom.hex
    end
  end
end
