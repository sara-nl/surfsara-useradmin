class Migration < ApplicationRecord
  class Index < Operation
    include Collection
    include Policy::Guard

    policy do |params|
      params[:current_user].surfsara_admin?
    end

    def model!(params)
      Migration
        .order(created_at: :desc)
        .page(params[:page])
    end
  end
end
