class Migration < ApplicationRecord
  class Policy < BasePolicy
    def index?
      current_user.surfsara_admin?
    end
  end
end
