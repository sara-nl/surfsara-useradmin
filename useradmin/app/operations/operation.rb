class Operation < Trailblazer::Operation
  def current_user
    @params[:current_user]
  end
end
