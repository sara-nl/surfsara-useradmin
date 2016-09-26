require "reform/form/validation/unique_validator"
require 'digest/sha1'

class Invite < ApplicationRecord
  class Create < Operation
    include Model
    model Invite, :create

    contract do
      property :email, validates: {presence: true, email: true}
      property :group_id, validates: {presence: true}
      property :group_name, validates: {presence: true}
      property :role, validates: {presence: true, inclusion: {in: Role.for_group}}
      property :ignore_email_duplicity, virtual: true

      validate :email do
        unless ignore_email_duplicity?
          base = Invite.with_email(email).where(group_id: group_id, role: role)
          invites = base.pending.or(base.accepted)
          errors.add :base, :duplicate if invites.any?
        end
      end

      def ignore_email_duplicity?
        self.ignore_email_duplicity == '1'
      end
    end

    def process(params)
      validate(params[:invite], @model) do
        contract.save && send_invitation!
      end
    end

    private

    def model!(_params)
      Invite.new(token: invite_token.hashed, group_name: group_name, created_by: current_user.one_username)
    end

    def send_invitation!
      InviteMailer.invitation(@model, invite_token.raw, sender).deliver_now
    end

    def sender
      return nil if current_user.primary_email_address.blank?
      "#{current_user.common_name} <#{current_user.primary_email_address}>"
    end

    def invite_token
      @invite_token ||= InviteToken.random
    end

    def group_name
      return if group_id.blank?
      current_user.admin_groups.find { |g| g.id == group_id }&.name
    end

    def group_id
      group_id = @params.dig(:invite, :group_id)
      group_id.present? ? group_id.to_i : nil
    end
  end
end
