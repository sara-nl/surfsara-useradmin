require 'digest/sha1'

class Invite < ApplicationRecord
  class Index < Operation
    include Collection

    def model!(params)
      Invite.for_user(current_user).order(created_at: :desc)
    end
  end
end
