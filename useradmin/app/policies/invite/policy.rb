class Invite < ApplicationRecord
  class Policy < BasePolicy
    def index?
      current_user.can_administer_groups?
    end

    def create?
      current_user.can_administer_groups?
    end

    def revoke?
      current_user.can_administer_groups?
    end

    def accept?
      true
    end
  end
end
