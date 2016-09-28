class BasePolicy
  def initialize(current_user, model = nil)
    @current_user = current_user
    @model = model
  end

  private

  attr_reader :current_user, :model
end
