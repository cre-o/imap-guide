class CreateUploads < ActiveRecord::Migration
  def up
    create_table :uploads do |t|
      t.references :user, index: true
      t.references :location, index: true
      t.string :description
      t.string :state, null: false, default: 'pending', index: true
      t.timestamps
    end

    add_attachment :uploads, :image
  end

  def down
    drop_table :uploads
  end
end
