class MigrationsController < ApplicationController
  def new
    hide_menu
    form One::MigrateUser
  end

  def create
    hide_menu
    run One::MigrateUser do |_op|
      flash[:success] = t('.success')
      return redirect_to action: :success
    end

    render :new
  end

  def success
    hide_menu unless current_user.can_administer_groups?
  end

  def index
    present Migration::Index
  end
end
