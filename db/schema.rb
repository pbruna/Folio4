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

ActiveRecord::Schema.define(version: 20151231211508) do

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
    t.string   "industry",                         default: ""
    t.boolean  "e_invoice_enabled",                default: false
    t.date     "e_invoice_resolution_date"
    t.string   "e_invoice_regional_address"
    t.integer  "industry_code"
    t.integer  "dte_nc_start_number",              default: 0
    t.integer  "dte_invoice_start_number",         default: 0
    t.boolean  "dte_testing"
    t.integer  "dte_invoice_untaxed_start_number"
    t.integer  "e_invoice_resolution_number"
  end

  add_index "accounts", ["dte_testing"], name: "index_accounts_on_dte_testing"
  add_index "accounts", ["owner_id"], name: "index_accounts_on_owner_id", unique: true
  add_index "accounts", ["plan_id"], name: "index_accounts_on_plan_id"
  add_index "accounts", ["rut"], name: "index_accounts_on_rut"
  add_index "accounts", ["subdomain"], name: "index_accounts_on_subdomain"

  create_table "attachments", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "resource_file_name"
    t.string   "resource_content_type"
    t.integer  "resource_file_size"
    t.datetime "resource_updated_at"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "account_id"
    t.string   "original_file_name"
  end

  add_index "attachments", ["account_id"], name: "index_attachments_on_account_id"
  add_index "attachments", ["author_id", "author_type"], name: "index_attachments_on_author_id_and_author_type"

  create_table "audits", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audits", ["account_id"], name: "index_audits_on_account_id"
  add_index "audits", ["user_id"], name: "index_audits_on_user_id"

  create_table "comments", force: true do |t|
    t.string   "subject"
    t.text     "message"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "account_users_ids"
    t.string   "company_users_ids"
    t.boolean  "private",           default: false
    t.boolean  "from_email",        default: false
  end

  add_index "comments", ["author_id"], name: "index_comments_on_author_id"
  add_index "comments", ["author_type"], name: "index_comments_on_author_type"
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type"

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
    t.string   "alias"
    t.string   "country"
  end

  add_index "companies", ["account_id"], name: "index_companies_on_account_id"
  add_index "companies", ["name"], name: "index_companies_on_name"
  add_index "companies", ["rut"], name: "index_companies_on_rut"

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mobile_phone"
    t.string   "title"
    t.text     "description"
  end

  add_index "contacts", ["company_id"], name: "index_contacts_on_company_id"

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

  create_table "dtes", force: true do |t|
    t.integer  "tipo_dte",                                              null: false
    t.integer  "folio",                                                 null: false
    t.date     "fch_emis",                                              null: false
    t.integer  "fma_pago",                              default: 1
    t.date     "fch_venc",                                              null: false
    t.string   "rut_emisor",                                            null: false
    t.string   "rzn_soc",                                               null: false
    t.string   "giro_emis",                                             null: false
    t.integer  "acteco",                                                null: false
    t.string   "dir_origen",                                            null: false
    t.string   "cmna_origen",                                           null: false
    t.string   "rut_recep",                                             null: false
    t.string   "rzn_soc_recep",                                         null: false
    t.integer  "mnt_neto"
    t.integer  "mnt_exe",                               default: 0,     null: false
    t.decimal  "tasa_iva",      precision: 6, scale: 2, default: 19.0
    t.integer  "iva",                                   default: 0
    t.integer  "mnt_total",                             default: 0
    t.string   "pdf_url"
    t.integer  "account_id",                                            null: false
    t.integer  "company_id",                                            null: false
    t.integer  "invoice_id",                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processed",                             default: false
    t.text     "error_log"
    t.integer  "cod_ref"
    t.string   "razon_ref"
    t.integer  "folio_ref"
    t.date     "fch_ref"
    t.integer  "tpo_doc_ref"
    t.string   "giro_recep"
    t.string   "cmna_recep"
    t.string   "dir_recep"
    t.string   "contacto"
    t.string   "cond_pago"
  end

  add_index "dtes", ["account_id"], name: "index_dtes_on_account_id"
  add_index "dtes", ["company_id"], name: "index_dtes_on_company_id"
  add_index "dtes", ["invoice_id"], name: "index_dtes_on_invoice_id"

  create_table "expenses", force: true do |t|
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expenses", ["account_id"], name: "index_expenses_on_account_id"

  create_table "invoice_items", force: true do |t|
    t.integer  "account_id"
    t.integer  "quantity",                             default: 0
    t.text     "description"
    t.decimal  "price",       precision: 15, scale: 4, default: 0.0
    t.decimal  "total",       precision: 15, scale: 4, default: 0.0
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "number",                               default: 1
  end

  add_index "invoice_items", ["account_id"], name: "index_invoice_items_on_account_id"
  add_index "invoice_items", ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  add_index "invoice_items", ["type"], name: "index_invoice_items_on_type"

  create_table "invoices", force: true do |t|
    t.integer  "number"
    t.decimal  "tax_total",                                         default: 0.0
    t.decimal  "net_total",                                         default: 0.0
    t.decimal  "total",                                             default: 0.0
    t.integer  "company_id"
    t.integer  "contact_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "taxed"
    t.date     "due_date"
    t.date     "active_date"
    t.date     "close_date"
    t.string   "subject"
    t.integer  "tax_id"
    t.string   "tax_name"
    t.float    "tax_rate"
    t.string   "aasm_state",                                        default: "draft"
    t.string   "currency",                                          default: "clp"
    t.integer  "due_days",                                          default: 30
    t.float    "currency_convertion_rate",                          default: 1.0
    t.decimal  "original_currency_total",  precision: 20, scale: 4, default: 0.0
    t.decimal  "total_payed",                                       default: 0.0
    t.string   "po_number"
  end

  add_index "invoices", ["aasm_state"], name: "index_invoices_on_aasm_state"
  add_index "invoices", ["account_id"], name: "index_invoices_on_account_id"
  add_index "invoices", ["company_id"], name: "index_invoices_on_company_id"
  add_index "invoices", ["contact_id"], name: "index_invoices_on_contact_id"
  add_index "invoices", ["currency"], name: "index_invoices_on_currency"
  add_index "invoices", ["tax_id"], name: "index_invoices_on_tax_id"

  create_table "money_accounts", force: true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.string   "number"
    t.string   "description"
    t.string   "bank_name"
    t.integer  "type_id"
    t.integer  "total_credit_clp", default: 0
    t.integer  "total_credit_usd", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "money_accounts", ["account_id"], name: "index_money_accounts_on_account_id"
  add_index "money_accounts", ["type_id"], name: "index_money_accounts_on_type_id"

  create_table "plans", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reconcilations", force: true do |t|
    t.decimal  "debit",            precision: 10, scale: 0, default: 0
    t.decimal  "debt",             precision: 10, scale: 0, default: 0
    t.string   "currency",                                  default: "clp"
    t.integer  "user_id",                                                   null: false
    t.integer  "money_account_id",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reconcilations", ["currency"], name: "index_reconcilations_on_currency"
  add_index "reconcilations", ["money_account_id"], name: "index_reconcilations_on_money_account_id"
  add_index "reconcilations", ["user_id"], name: "index_reconcilations_on_user_id"

  create_table "reminders", force: true do |t|
    t.date     "notification_date"
    t.integer  "remindable_id"
    t.string   "remindable_type"
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_days"
    t.date     "due_date"
    t.string   "subject"
    t.text     "message"
    t.boolean  "active",            default: false
    t.text     "account_users_ids"
    t.text     "company_users_ids"
  end

  add_index "reminders", ["remindable_id"], name: "index_reminders_on_remindable_id"

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
