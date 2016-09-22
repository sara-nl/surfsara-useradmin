class AddRevokedAttributesToInvite < ActiveRecord::Migration[5.0]
  def change
    add_column :invites, :revoked_at, :datetime
    add_column :invites, :revoked_by, :string
  end
end
