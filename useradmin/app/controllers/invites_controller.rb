class InvitesController < ApplicationController
  def index
    params[:current_user] = current_user
    present Invite::Index
  end

  def show
    @invite = Invite.find(params[:id])
  end

  def new
    @groups = groups
    @form = Invite.new
  end

  def create
    run Invite::Create do |op|
      flash[:success] = t('.success', model: Invite.model_name)
      return redirect_to(op.model)
    end

    @groups = groups
    render :new
  end

  def destroy
    run Invite::Destroy
    redirect_to invites_path
  end

  def accept
    render text: 'Your invitation has been accepted...'
  end

  private

  def groups
    OneClient.groups
      .sort_by { |g| g.name }
      .map { |g| [g.name, g.id] }
  end
end
