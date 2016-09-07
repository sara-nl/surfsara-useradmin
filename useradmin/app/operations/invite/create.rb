require 'digest/sha1'

class Invite < ActiveRecord::Base
  class Create < Operation
    contract do
      property :email, validates: { presence: true }
      property :group_id, validates: { presence: true }
      property :group_name
    end

    def process(params)
      @model = Invite.new(token: encrypted_token, group_name: group_name)

      validate(params[:invite], @model) do
        contract.save
        send_invitation!
      end
    end

    private

    def send_invitation!
      InviteMailer.invitation(@model.email, random_token, group_name).deliver_now
    end

    def encrypted_token
      Digest::SHA2.hexdigest(random_token)
    end

    def random_token
      @random_token ||= SecureRandom.hex
    end

    def group_name
      return if group_id.blank?
      OneClient.groups.find { |g| g.id == group_id }.name
    end

    def group_id
      group_id = @params[:invite][:group_id]
      group_id.present? ? group_id.to_i : nil
    end
  end
end
