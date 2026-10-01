class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.uuid :customer_id, null: false
      t.uuid :user_id, null: false
      t.uuid :device_id, null: false
      t.string :source, null: false, default: "whatsapp_business"
      t.string :external_identifier
      t.uuid :capture_uuid, null: false
      t.datetime :captured_at, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps type: :timestamptz
    end

    add_conversation_indexes
    add_tenant_foreign_keys
    add_check_constraint :conversations, "source IN ('whatsapp_business')", name: "conversations_source_check"
  end

  private

  def add_conversation_indexes
    add_index :conversations, :capture_uuid, unique: true
    add_index :conversations, %i[id organization_id], unique: true
    add_index :conversations, %i[organization_id customer_id]
    add_index :conversations, %i[organization_id captured_at]
  end

  def add_tenant_foreign_keys
    add_foreign_key :conversations, :customers,
      column: %i[customer_id organization_id], primary_key: %i[id organization_id]
    add_foreign_key :conversations, :users,
      column: %i[user_id organization_id], primary_key: %i[id organization_id]
    add_foreign_key :conversations, :devices,
      column: %i[device_id organization_id], primary_key: %i[id organization_id]
  end
end
