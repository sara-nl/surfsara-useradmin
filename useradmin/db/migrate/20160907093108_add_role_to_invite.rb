class AddRoleToInvite < ActiveRecord::Migration
  def change
    add_column :invites, :role, :string
  end
end
