class Invite < ApplicationRecord
  class Policy < BasePolicy
    def index?
      current_user.can_administer_groups?
    end

    def show?
      current_user.admin_groups.map(&:id).include?(model.group_id)
    end

    def create?
      current_user.can_administer_groups?
    end

    def revoke?
      current_user.admin_groups.map(&:id).include?(model.group_id)
    end

    def accept?
      true
    end

    def accepted?
      model.accepted_by == current_user.remote_user
    end
  end
end
