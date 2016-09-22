class InvitesController < ApplicationController
  def index
    present Invite::Index
  end

  def show
    @invite = Invite.scoped_to(current_user).find(params[:id])
  end

  def new
    @groups = groups
    form Invite::Create
  end

  def create
    run Invite::Create do |op|
      flash[:success] = t('.success')
      return redirect_to(op.model)
    end

    @groups = groups
    render :new
  end

  def revoke
    run Invite::Revoke
    redirect_to invites_path
  end

  def verify
    hide_menu
    @form = form Invite::Accept
    render :expired unless @form.model
  end

  def accept
    hide_menu

    run Invite::Accept do |_op|
      flash[:success] = t('.success')
      return redirect_to accepted_invite_path(params[:id])
    end

    @groups = groups
    render :verify
  end

  def accepted
    hide_menu
    invite_token = InviteToken.new(params[:id])
    @model = Invite.find_by!(accepted_by: current_user.one_username, token: invite_token.encrypted)
  end

  private

  def groups
    current_user.admin_groups
      .sort_by(&:name)
      .map { |g| [g.name, g.id] }
  end

  def hide_menu
    @hide_menu = true
  end
end
