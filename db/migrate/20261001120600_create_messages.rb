class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.uuid :conversation_id, null: false
      t.string :sender_type, null: false
      t.string :content_type, null: false, default: "text"
      t.text :body, null: false
      t.datetime :occurred_at, null: false
      t.string :external_identifier
      t.jsonb :metadata, null: false, default: {}
      t.timestamps type: :timestamptz
    end

    add_message_indexes
    add_message_constraints
    add_foreign_key :messages, :conversations,
      column: %i[conversation_id organization_id], primary_key: %i[id organization_id]
  end

  private

  def add_message_indexes
    add_index :messages, %i[conversation_id occurred_at]
    add_index :messages, %i[organization_id occurred_at]
    add_index :messages, %i[conversation_id external_identifier],
      unique: true, where: "external_identifier IS NOT NULL"
  end

  def add_message_constraints
    add_check_constraint :messages,
      "sender_type IN ('customer', 'seller', 'unknown')", name: "messages_sender_type_check"
    add_check_constraint :messages,
      "content_type IN ('text', 'image', 'audio', 'document', 'unknown')", name: "messages_content_type_check"
  end
end
