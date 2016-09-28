class InvitesController < ApplicationController
  def index
    present Invite::Index
  end

  def show
    present Invite::Show
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
    @form = form Invite::Accept
    hide_menu
    render :expired unless @form.model
  end

  def accept
    res, op = Invite::Accept.run(params)
    hide_menu
    handle_accept(res, op)
  end

  def accepted
    present Invite::Accepted
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
