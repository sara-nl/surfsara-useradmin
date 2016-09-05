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
      return redirect_to(op.model), notice: 'Success!'
    end

    render :new
  end

  def update
    run Invite::Update do |op|
      return redirect_to(op.model)
    end

    render :edit
  end

  def destroy
    run Invite::Destroy
    redirect_to invites_path
  end
end
