class Invite < ActiveRecord::Base
  class Destroy < Operation
    include Model

    model Invite, :find

    def process(_)
      model.destroy
    end
  end
end
