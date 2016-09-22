class AddCreatedByToInvite < ActiveRecord::Migration[5.0]
  def change
    add_column :invites, :created_by, :string
  end
end
