class InvitesController < ApplicationController
  def index
    @invites = Invite.all
  end

  def show
    @invite = Invite.find(params[:id])
  end

  def new
    form Invite::Create
  end

  def edit
    form Invite::Update
  end

  def create
    run Invite::Create do |op|
      flash[:notice] = t('actions.create.success', model: Invite.model_name)
      return redirect_to(op.model)
    end

    render :new
  end

  def update
    run Invite::Update do |op|
      flash[:notice] = t('actions.update.success', model: Invite.model_name)
      return redirect_to(op.model)
    end

    render :edit
  end

  def destroy
    run Invite::Destroy
    redirect_to invites_path
  end
end
