class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers, id: :uuid do |t|
      t.references :organization, null: false, type: :uuid, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :company_name
      t.string :external_crm_id
      t.jsonb :metadata, null: false, default: {}
      t.timestamps type: :timestamptz
    end

    add_index :customers, :phone
    add_index :customers, :external_crm_id
    add_index :customers, %i[organization_id phone]
    add_index :customers, %i[organization_id external_crm_id]
    add_index :customers, %i[id organization_id], unique: true
  end
end
