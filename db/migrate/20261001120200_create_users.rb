class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, null: false, default: "seller"
      t.boolean :active, null: false, default: true
      t.timestamps type: :timestamptz
    end

    add_index :users, %i[organization_id email], unique: true
    add_index :users, %i[id organization_id], unique: true
    add_check_constraint :users, "role IN ('admin', 'seller')", name: "users_role_check"
  end
end
