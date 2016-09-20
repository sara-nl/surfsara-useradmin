class Invite < ApplicationRecord
  STATUS_PENDING = 'pending'.freeze
  STATUS_ACCEPTED = 'accepted'.freeze
  STATUS_EXPIRED = 'expired'.freeze

  def status
    return STATUS_ACCEPTED if accepted?
    return STATUS_EXPIRED if expired?
    STATUS_PENDING
  end

  private

  def accepted?
    accepted_at.present?
  end

  def expired?
    return false unless created_at
    created_at < 5.minutes.ago
  end

  def self.scoped_to(user)
    where(group_id: user.admin_groups.map(&:id))
  end
end
