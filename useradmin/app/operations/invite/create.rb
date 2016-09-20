require 'digest/sha1'

class Invite < ApplicationRecord
  class Create < Operation
    include Model
    model Invite, :create

    contract do
      property :email, validates: {presence: true, email: true}
      property :group_id, validates: {presence: true}
      property :group_name
      property :role, validates: {presence: true, inclusion: {in: Role.for_group}}
    end

    def process(params)
      @model = Invite.new(token: invite_token.encrypted, group_name: group_name)

      validate(params[:invite], @model) do
        contract.save
        send_invitation!
      end
    end

    private

    def send_invitation!
      InviteMailer.invitation(@model, invite_token.raw).deliver_now
    end

    def invite_token
      @invite_token ||= InviteToken.random
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
