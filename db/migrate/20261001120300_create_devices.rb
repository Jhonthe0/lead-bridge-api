class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.uuid :user_id, null: false
      t.string :device_uuid, null: false
      t.string :name, null: false
      t.string :platform, null: false, default: "android"
      t.string :app_version
      t.string :token_digest, null: false
      t.datetime :last_seen_at
      t.boolean :active, null: false, default: true
      t.timestamps type: :timestamptz
    end

    add_index :devices, :device_uuid, unique: true
    add_index :devices, :token_digest, unique: true
    add_index :devices, %i[id organization_id], unique: true
    add_foreign_key :devices, :users,
      column: %i[user_id organization_id], primary_key: %i[id organization_id]
  end
end
