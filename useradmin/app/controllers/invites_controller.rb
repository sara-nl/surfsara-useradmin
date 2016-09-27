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

    res, op = Invite::Accept.run(params)
    handle_accept(res, op)
  end

  def accepted
    invite_token = InviteToken.new(params[:id])
    @model = Invite.find_by!(accepted_by: current_user.edu_person_principal_name, token: invite_token.hashed)
    hide_menu unless current_user.can_administer_groups?
  end

  private

  def groups
    current_user.admin_groups
      .sort_by(&:name)
      .map { |g| [g.name, g.id] }
  end

  def handle_accept(res, op)
    if res
      flash[:success] = t('.success')
      redirect_to accepted_invite_path(params[:id])
    elsif op.model
      @model = op.model
      @form = op.contract
      render :verify
    else
      render :expired
    end
  end
end
