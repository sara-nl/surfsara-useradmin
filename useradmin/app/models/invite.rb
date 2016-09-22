class Invite < ApplicationRecord
  STATUS_PENDING = 'pending'.freeze
  STATUS_ACCEPTED = 'accepted'.freeze
  STATUS_EXPIRED = 'expired'.freeze
  STATUS_REVOKED = 'revoked'.freeze

  scope :pending, -> do
    where(accepted_at: nil)
      .where(revoked_at: nil)
      .where('created_at > ?', Rails.application.config.invites.expire_after.ago)
  end

  def self.scoped_to(user)
    where(group_id: user.admin_groups.map(&:id))
  end

  def status
    return STATUS_ACCEPTED if accepted?
    return STATUS_REVOKED if revoked?
    return STATUS_EXPIRED if expired?
    STATUS_PENDING
  end

  def pending?
    !accepted? && !revoked? && !expired?
  end

  private

  def accepted?
    accepted_at.present?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    return false unless created_at
    created_at < Rails.application.config.invites.expire_after.ago
  end
end
