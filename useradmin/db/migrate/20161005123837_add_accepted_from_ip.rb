class AddAcceptedFromIp < ActiveRecord::Migration[5.0]
  def change
    add_column :invites, :accepted_from_ip, :string
    add_column :migrations, :accepted_from_ip, :string
  end
end
