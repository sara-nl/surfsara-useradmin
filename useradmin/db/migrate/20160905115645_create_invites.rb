class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :email
      t.string :token
      t.string :accepted_by
      t.datetime :accepted_at

      t.timestamps null: false
    end
  end
end
