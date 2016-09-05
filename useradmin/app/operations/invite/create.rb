class Invite < ActiveRecord::Base
  class Create < Operation
    model Invite, :create

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
