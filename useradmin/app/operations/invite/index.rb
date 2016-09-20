require 'digest/sha1'

class Invite < ApplicationRecord
  class Index < Operation
    include Collection

    def model!(params)
      Invite
        .where(group_id: current_user.admin_groups.map(&:id))
        .order(created_at: :desc)
    end
  end
end
