# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131029004622) do

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.integer  "owner_id"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rut"
    t.string   "address"
    t.string   "city"
    t.string   "phone"
    t.string   "country"
  end

  add_index "accounts", ["owner_id"], name: "index_accounts_on_owner_id", unique: true
  add_index "accounts", ["plan_id"], name: "index_accounts_on_plan_id"
  add_index "accounts", ["rut"], name: "index_accounts_on_rut"
  add_index "accounts", ["subdomain"], name: "index_accounts_on_subdomain"

  create_table "audits", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audits", ["account_id"], name: "index_audits_on_account_id"
  add_index "audits", ["user_id"], name: "index_audits_on_user_id"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rut"
    t.string   "address"
    t.string   "city"
    t.string   "province"
    t.string   "phone"
    t.string   "industry"
    t.integer  "account_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "companies", ["account_id"], name: "index_companies_on_account_id"
  add_index "companies", ["name"], name: "index_companies_on_name"
  add_index "companies", ["rut"], name: "index_companies_on_rut"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "expenses", force: true do |t|
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expenses", ["account_id"], name: "index_expenses_on_account_id"

  create_table "invoice_items", force: true do |t|
    t.integer  "account_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.text     "description"
    t.integer  "price"
    t.integer  "total_amount", default: 0
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_items", ["account_id"], name: "index_invoice_items_on_account_id"
  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  add_index "invoice_items", ["product_id"], name: "index_invoice_items_on_product_id"

  create_table "invoices", force: true do |t|
    t.integer  "number",       default: 0
    t.decimal  "tax_amount",   default: 0.0
    t.decimal  "net_amount",   default: 0.0
    t.decimal  "total_amount", default: 0.0
    t.integer  "company_id"
    t.integer  "contact_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "taxed"
    t.date     "due_date"
    t.date     "open_date"
    t.date     "close_date"
    t.string   "subject"
    t.integer  "tax_id"
    t.string   "tax_name"
    t.float    "tax_rate"
  end

  add_index "invoices", ["account_id"], name: "index_invoices_on_account_id"
  add_index "invoices", ["company_id"], name: "index_invoices_on_company_id"
  add_index "invoices", ["contact_id"], name: "index_invoices_on_contact_id"
  add_index "invoices", ["tax_id"], name: "index_invoices_on_tax_id"

  create_table "plans", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "account_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.boolean  "active"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email", "account_id"], name: "index_users_on_email_and_account_id", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
