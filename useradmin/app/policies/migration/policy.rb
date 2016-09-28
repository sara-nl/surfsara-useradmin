class Migration < ApplicationRecord
  class Policy < BasePolicy
    def index?
      current_user.surfsara_admin?
    end

    def create?
      true
    end
  end
end
