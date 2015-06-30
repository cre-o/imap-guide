class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float :lat, percision: 10, scale: 6, null: false
      t.float :lng, percision: 10, scale: 6, null: false
      t.references :user, null: false
      t.timestamps null: false
    end

    add_index :locations, :lat
    add_index :locations, :lng
    add_index :locations, :user_id
  end
end
