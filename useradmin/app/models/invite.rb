class Invite < ApplicationRecord
  STATUS_PENDING = 'pending'.freeze
  STATUS_ACCEPTED = 'accepted'.freeze
  STATUS_EXPIRED = 'expired'.freeze
  STATUS_REVOKED = 'revoked'.freeze

  before_validation :normalize_email

  scope :pending, -> do
    where(accepted_at: nil)
      .where(revoked_at: nil)
      .where('created_at > ?', Rails.application.config.invites.expire_after.ago)
  end

  scope :accepted, -> do
    where.not(accepted_at: nil)
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

  def accepted?
    accepted_at.present?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    return false unless created_at
    return false if accepted?
    return false if revoked?
    created_at < Rails.application.config.invites.expire_after.ago
  end

  def expired_at
    return unless expired?
    self.created_at + Rails.application.config.invites.expire_after
  end

  private

  def normalize_email
    self.email = self.email.downcase.strip if self.email.present?
  end
end
