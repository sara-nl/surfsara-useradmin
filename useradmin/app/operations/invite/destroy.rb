class Invite < ActiveRecord::Base
  class Destroy < Operation
    model Invite, :find

    def process(_)
      model.destroy
    end
  end
end
