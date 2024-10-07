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

ActiveRecord::Schema[7.0].define(version: 2024_10_03_162857) do
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

  create_table "blogs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.string "slug"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "content_json", default: {}
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "call_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "phone_number"
    t.datetime "call_start_time"
    t.datetime "call_end_time"
    t.integer "duration"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "call_type"
    t.index ["user_id"], name: "index_call_logs_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "shop_product_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["shop_product_id"], name: "index_cart_items_on_shop_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "csp_daily_details", force: :cascade do |t|
    t.string "merchant_id", null: false
    t.integer "user_id", null: false
    t.string "name"
    t.decimal "amount", null: false
    t.integer "status"
    t.string "code"
    t.integer "organization_id"
    t.json "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gpt_prompt_responses", force: :cascade do |t|
    t.integer "gpt_prompt_id"
    t.string "prompt"
    t.string "response"
    t.json "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gpt_prompts", force: :cascade do |t|
    t.string "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "conversations", default: []
    t.string "code"
  end

  create_table "inbound_emails", force: :cascade do |t|
    t.json "meta", default: {}
    t.json "json", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "purpose"
  end

  create_table "libraries", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.integer "capacity"
    t.text "description"
    t.integer "num_staff"
    t.integer "num_books"
    t.integer "num_members"
    t.boolean "offers_membership"
    t.boolean "has_cafeteria"
    t.boolean "has_meeting_rooms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "magic_links", force: :cascade do |t|
    t.integer "link_type"
    t.string "redirect_to"
    t.string "auth_user_id"
    t.string "code"
    t.datetime "expires_on"
    t.string "description"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "shop_product_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["shop_product_id"], name: "index_order_items_on_shop_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "total_price"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "meta", default: {}
    t.string "payment_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "email_address"
    t.string "website"
    t.string "whatsapp_number"
    t.string "address"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "webhook_url"
  end

  create_table "payments", force: :cascade do |t|
    t.string "merchant_transaction_id", null: false
    t.string "merchant_id", null: false
    t.integer "user_id", null: false
    t.string "name"
    t.decimal "amount", null: false
    t.integer "status"
    t.string "code"
    t.integer "organization_id"
    t.json "gateway_params", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_categories", force: :cascade do |t|
    t.integer "name"
    t.text "description"
    t.string "keywords", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.bigint "product_category_id"
    t.string "name"
    t.text "description"
    t.string "image_url"
    t.integer "max_price"
    t.string "keywords", default: [], array: true
    t.integer "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.integer "owner_id"
    t.integer "status"
    t.json "meta", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shop_products", force: :cascade do |t|
    t.string "title"
    t.float "price"
    t.text "description"
    t.string "category"
    t.string "image"
    t.jsonb "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "user_otps", force: :cascade do |t|
    t.integer "user_id"
    t.integer "purpose"
    t.string "otp"
    t.datetime "valid_till"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "last_synced"
    t.integer "organization_id"
    t.json "meta", default: {}
    t.integer "school_id"
    t.text "app_session_token"
    t.datetime "app_session_expires_at"
    t.text "fcm_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

