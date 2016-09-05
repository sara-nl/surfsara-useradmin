class InvitesController < ApplicationController
  def index
    @invites = invites
  end

  def show
    @invite = invite
  end

  def new
    @invite = Invite.new
  end

  def edit
    @invite = invite
  end

  def create
    @invite = Invite.new(invite_params)

    if @invite.save
      redirect_to @invite, notice: 'Invite was successfully created.'
    else
      render :new
    end
  end

  def update
    if @invite.update(invite_params)
      redirect_to @invite, notice: 'Invite was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @invite.destroy
    redirect_to invites_url, notice: 'Invite was successfully destroyed.'
  end

  private

  def invite
    Invite.find(params[:id])
  end

  def invites
    Invite.all
  end

  def invite_params
    params.require(:invite).permit(:email, :token, :accepted_by, :accepted_at)
  end
end
