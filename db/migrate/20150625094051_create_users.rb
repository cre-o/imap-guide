class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :role, null: false, default: 1
      t.string :name
      t.string :surname
      t.timestamps null: false
    end

    add_index :users, :role_id
  end
end
