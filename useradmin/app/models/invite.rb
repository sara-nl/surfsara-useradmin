class Invite < ApplicationRecord
  def status
    return 'accepted' if accepted_at.present?
    'pending'
  end

  def self.scoped_to(user)
    where(group_id: user.admin_groups.map(&:id))
  end
end
