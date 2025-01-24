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

ActiveRecord::Schema[7.0].define(version: 2025_01_22_194301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "inbound_emails", force: :cascade do |t|
    t.string "subject"
    t.text "summary"
    t.datetime "received_time"
    t.text "content"
    t.string "to_address"
    t.string "from_address"
    t.string "card_number"
    t.string "otp"
    t.json "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "purpose"
  end

  create_table "inbound_otps", force: :cascade do |t|
    t.string "subject"
    t.text "summary"
    t.datetime "received_time"
    t.text "content"
    t.string "to_address"
    t.string "from_address"
    t.string "card_number"
    t.string "otp"
    t.json "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "key_value_stores", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_links", force: :cascade do |t|
    t.bigint "source_page_id", null: false
    t.bigint "target_page_id"
    t.string "target_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_page_id", "target_url"], name: "index_page_links_on_source_page_id_and_target_url", unique: true
    t.index ["source_page_id"], name: "index_page_links_on_source_page_id"
    t.index ["target_page_id"], name: "index_page_links_on_target_page_id"
  end

  create_table "scraped_pages", force: :cascade do |t|
    t.bigint "scraping_job_id", null: false
    t.string "url", null: false
    t.text "content"
    t.integer "depth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "meta_description"
    t.text "main_content"
    t.text "raw_html"
    t.string "status", default: "pending"
    t.string "meta_image"
    t.index ["scraping_job_id", "url"], name: "index_scraped_pages_on_scraping_job_id_and_url", unique: true
    t.index ["scraping_job_id"], name: "index_scraped_pages_on_scraping_job_id"
  end

  create_table "scraping_jobs", force: :cascade do |t|
    t.string "base_url", null: false
    t.integer "nest_depth"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "actual_depth"
    t.datetime "completed_at"
    t.text "error_message"
    t.index ["base_url"], name: "index_scraping_jobs_on_base_url"
  end

  create_table "tg_task_details", force: :cascade do |t|
    t.integer "tg_task_id"
    t.integer "tg_user_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_data"
    t.json "meta", default: {}
  end

  create_table "tg_task_submissions", force: :cascade do |t|
    t.integer "tg_task_id"
    t.integer "tg_user_id"
    t.integer "status"
    t.integer "submission_type"
    t.text "description"
    t.string "uploaded_files", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.boolean "is_paid", default: false
    t.float "earning"
    t.json "meta", default: {}
  end

  create_table "tg_tasks", force: :cascade do |t|
    t.float "cost"
    t.string "name"
    t.text "description"
    t.integer "status"
    t.integer "submission_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "links", default: [], array: true
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "maximum_per_user"
    t.integer "minimum_gap_in_hours"
    t.boolean "is_private", default: false
    t.string "custom_fields", default: [], array: true
    t.json "custom_field_values", default: {}
  end

  create_table "tg_users", force: :cascade do |t|
    t.string "chat_id"
    t.string "name"
    t.boolean "blocked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_task_id"
    t.string "submission_step"
    t.integer "last_prompt_message_id"
    t.string "code"
    t.float "total_earning"
    t.string "wallet_address"
    t.integer "wallet_message_id"
    t.string "remarks"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "country_code"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.json "meta", default: {}
    t.integer "school_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "page_links", "scraped_pages", column: "source_page_id"
  add_foreign_key "page_links", "scraped_pages", column: "target_page_id"
  add_foreign_key "scraped_pages", "scraping_jobs"
end
