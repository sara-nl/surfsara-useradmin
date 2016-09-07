class AddGroupFieldsToInvite < ActiveRecord::Migration
  def change
    add_column :invites, :group_id, :integer
    add_column :invites, :group_name, :string
  end
end
