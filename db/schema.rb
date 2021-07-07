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

ActiveRecord::Schema.define(version: 2021_07_07_105724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.bigint "version_id", null: false
    t.bigint "package_id", null: false
    t.string "url"
    t.integer "size"
    t.string "cid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "integrity"
    t.integer "pin_id"
    t.datetime "pinned_at"
    t.string "pin_status"
    t.integer "deal_id"
    t.index ["cid"], name: "index_archives_on_cid"
    t.index ["package_id"], name: "index_archives_on_package_id"
    t.index ["version_id"], name: "index_archives_on_version_id"
  end

  create_table "deals", force: :cascade do |t|
    t.integer "deal_id"
    t.bigint "size"
    t.integer "files_count"
    t.string "cid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "dependencies", force: :cascade do |t|
    t.integer "version_id"
    t.integer "package_id"
    t.string "package_name"
    t.string "platform"
    t.string "kind"
    t.boolean "optional", default: false
    t.string "requirements"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["package_id"], name: "index_dependencies_on_package_id"
    t.index ["version_id"], name: "index_dependencies_on_version_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.string "platform"
    t.text "description"
    t.text "keywords"
    t.string "homepage"
    t.string "licenses"
    t.string "repository_url"
    t.string "normalized_licenses", default: [], array: true
    t.integer "versions_count", default: 0, null: false
    t.datetime "latest_release_published_at"
    t.string "latest_release_number"
    t.string "keywords_array", default: [], array: true
    t.integer "dependents_count", default: 0, null: false
    t.string "language"
    t.string "status"
    t.datetime "last_synced_at"
    t.integer "runtime_dependencies_count"
    t.string "latest_stable_release_number"
    t.string "latest_stable_release_published_at"
    t.boolean "license_normalized", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["platform", "name"], name: "index_packages_on_platform_and_name", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.integer "package_id"
    t.string "number"
    t.datetime "published_at"
    t.integer "runtime_dependencies_count"
    t.string "spdx_expression"
    t.jsonb "original_license"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "integrity"
    t.boolean "yanked", default: false
    t.index ["package_id", "number"], name: "index_versions_on_package_id_and_number", unique: true
  end

  add_foreign_key "archives", "packages"
  add_foreign_key "archives", "versions"
end
