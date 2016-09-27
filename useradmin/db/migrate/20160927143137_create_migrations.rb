class CreateMigrations < ActiveRecord::Migration[5.0]
  def change
    create_table :migrations do |t|
      t.string :one_username, null: false
      t.string :accepted_by, null: false
      t.datetime :accepted_at, null: false
      t.timestamps
    end
  end
end
