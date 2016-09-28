class Migration < ApplicationRecord
  class Index < Operation
    include Collection
    include Trailblazer::Operation::Policy

    policy Migration::Policy, :index?

    def model!(params)
      Migration
        .order(created_at: :desc)
        .page(params[:page])
    end
  end
end
