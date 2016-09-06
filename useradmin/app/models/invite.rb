class Invite < ActiveRecord::Base
  def status
    return 'accepted' if accepted_at.present?
    'pending'
  end
end
