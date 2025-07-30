class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :likable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :likes, [:user_id, :likable_type, :likable_id], unique: true, name: "index_likes_on_user_and_likable"
  end
end
