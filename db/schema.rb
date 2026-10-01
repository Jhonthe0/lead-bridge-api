# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_01_120600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "customer_id", null: false
    t.uuid "user_id", null: false
    t.uuid "device_id", null: false
    t.string "source", default: "whatsapp_business", null: false
    t.string "external_identifier"
    t.uuid "capture_uuid", null: false
    t.datetime "captured_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capture_uuid"], name: "index_conversations_on_capture_uuid", unique: true
    t.index ["id", "organization_id"], name: "index_conversations_on_id_and_organization_id", unique: true
    t.index ["organization_id", "captured_at"], name: "index_conversations_on_organization_id_and_captured_at"
    t.index ["organization_id", "customer_id"], name: "index_conversations_on_organization_id_and_customer_id"
    t.index ["organization_id"], name: "index_conversations_on_organization_id"
    t.check_constraint "source::text = 'whatsapp_business'::text", name: "conversations_source_check"
  end

  create_table "customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "company_name"
    t.string "external_crm_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_crm_id"], name: "index_customers_on_external_crm_id"
    t.index ["id", "organization_id"], name: "index_customers_on_id_and_organization_id", unique: true
    t.index ["organization_id", "external_crm_id"], name: "index_customers_on_organization_id_and_external_crm_id"
    t.index ["organization_id", "phone"], name: "index_customers_on_organization_id_and_phone"
    t.index ["organization_id"], name: "index_customers_on_organization_id"
    t.index ["phone"], name: "index_customers_on_phone"
  end

  create_table "devices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "user_id", null: false
    t.string "device_uuid", null: false
    t.string "name", null: false
    t.string "platform", default: "android", null: false
    t.string "app_version"
    t.string "token_digest", null: false
    t.datetime "last_seen_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_uuid"], name: "index_devices_on_device_uuid", unique: true
    t.index ["id", "organization_id"], name: "index_devices_on_id_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_devices_on_organization_id"
    t.index ["token_digest"], name: "index_devices_on_token_digest", unique: true
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "conversation_id", null: false
    t.string "sender_type", null: false
    t.string "content_type", default: "text", null: false
    t.text "body", null: false
    t.datetime "occurred_at", null: false
    t.string "external_identifier"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "external_identifier"], name: "index_messages_on_conversation_id_and_external_identifier", unique: true, where: "(external_identifier IS NOT NULL)"
    t.index ["conversation_id", "occurred_at"], name: "index_messages_on_conversation_id_and_occurred_at"
    t.index ["organization_id", "occurred_at"], name: "index_messages_on_organization_id_and_occurred_at"
    t.index ["organization_id"], name: "index_messages_on_organization_id"
    t.check_constraint "content_type::text = ANY (ARRAY['text'::character varying, 'image'::character varying, 'audio'::character varying, 'document'::character varying, 'unknown'::character varying]::text[])", name: "messages_content_type_check"
    t.check_constraint "sender_type::text = ANY (ARRAY['customer'::character varying, 'seller'::character varying, 'unknown'::character varying]::text[])", name: "messages_sender_type_check"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "seller", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id", "organization_id"], name: "index_users_on_id_and_organization_id", unique: true
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying, 'seller'::character varying]::text[])", name: "users_role_check"
  end

  add_foreign_key "conversations", "customers", column: ["customer_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "conversations", "devices", column: ["device_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "conversations", "organizations"
  add_foreign_key "conversations", "users", column: ["user_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "customers", "organizations"
  add_foreign_key "devices", "organizations"
  add_foreign_key "devices", "users", column: ["user_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "messages", "conversations", column: ["conversation_id", "organization_id"], primary_key: ["id", "organization_id"]
  add_foreign_key "messages", "organizations"
  add_foreign_key "users", "organizations"
end
