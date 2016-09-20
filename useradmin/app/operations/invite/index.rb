require 'digest/sha1'

class Invite < ApplicationRecord
  class Index < Operation
    include Collection

    def model!(params)
      Invite
        .scoped_to(current_user)
        .order(created_at: :desc)
        .page(params[:page])
    end
  end
end
