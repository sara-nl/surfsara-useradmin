class Invite < ApplicationRecord
  def status
    return 'accepted' if accepted_at.present?
    'pending'
  end
end
