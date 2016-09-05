class Invite < ActiveRecord::Base
  class Update < Operation
    model Invite, :find

    contract do
      property :email, validates: { presence: true }
    end

    def process(params)
      validate(params[:invite]) do
        contract.save
      end
    end
  end
end
