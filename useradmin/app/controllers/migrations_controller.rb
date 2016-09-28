class MigrationsController < ApplicationController
  def new
    form One::MigrateUser
    hide_menu
  end

  def create
    run One::MigrateUser do |_op|
      flash[:success] = t('.success')
      return redirect_to action: :success
    end
    hide_menu

    render :new
  end

  def success
    hide_menu unless current_user.can_administer_groups?
  end

  def index
    present Migration::Index
  end
end
