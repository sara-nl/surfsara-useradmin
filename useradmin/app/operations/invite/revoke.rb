class Invite < ApplicationRecord
  class Revoke < Operation
    include Model
    model Invite, :find

    def process(_)
      model.destroy
    end
  end
end
