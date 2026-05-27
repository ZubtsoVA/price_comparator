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

ActiveRecord::Schema[8.1].define(version: 5) do
  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "platforms", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "base_url", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_platforms_on_slug", unique: true
  end

  create_table "prices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "amount", null: false
    t.bigint "platform_id", null: false
    t.bigint "product_id", null: false
    t.datetime "recorded_at", null: false
    t.index ["platform_id"], name: "index_prices_on_platform_id"
    t.index ["product_id", "platform_id", "recorded_at"], name: "index_prices_on_product_id_and_platform_id_and_recorded_at"
    t.index ["product_id", "recorded_at"], name: "index_prices_on_product_id_and_recorded_at"
    t.index ["product_id"], name: "index_prices_on_product_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "image_url"
    t.string "link", null: false
    t.string "name", null: false
    t.bigint "platform_id", null: false
    t.decimal "rating", precision: 3, scale: 1, default: "0.0"
    t.integer "reviews_qty", default: 0
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["link", "platform_id"], name: "index_products_on_link_and_platform_id", unique: true
    t.index ["platform_id"], name: "index_products_on_platform_id"
  end

  create_table "search_caches", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "cache_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.json "results", null: false
    t.datetime "updated_at", null: false
    t.index ["cache_key"], name: "index_search_caches_on_cache_key", unique: true
    t.index ["expires_at"], name: "index_search_caches_on_expires_at"
  end

  add_foreign_key "prices", "platforms"
  add_foreign_key "prices", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "platforms"
end
