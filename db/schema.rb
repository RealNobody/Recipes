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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130522043300) do

  create_table "container_aliases", :force => true do |t|
    t.integer  "container_id"
    t.string   "alias"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "container_aliases", ["alias"], :name => "index_container_aliases_on_alias", :unique => true
  add_index "container_aliases", ["container_id"], :name => "index_container_aliases_on_container_id"

  create_table "containers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ingredient_aliases", :force => true do |t|
    t.integer  "ingredient_id"
    t.string   "alias"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "ingredient_aliases", ["alias"], :name => "index_ingredient_aliases_on_alias", :unique => true
  add_index "ingredient_aliases", ["ingredient_id"], :name => "index_ingredient_aliases_on_ingredient_id"

  create_table "ingredient_categories", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ingredient_categories", ["order", "name"], :name => "index_ingredient_categories_on_order_and_name"

  create_table "ingredients", :force => true do |t|
    t.string   "name"
    t.integer  "measuring_unit_id"
    t.integer  "ingredient_category_id"
    t.text     "prep_instructions"
    t.text     "day_before_prep_instructions"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "keyword_aliases", :force => true do |t|
    t.string   "alias"
    t.integer  "keyword_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "measurement_aliases", :force => true do |t|
    t.string   "alias"
    t.integer  "measuring_unit_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "measurement_aliases", ["alias"], :name => "index_measurement_aliases_on_alias", :unique => true
  add_index "measurement_aliases", ["measuring_unit_id"], :name => "index_measurement_aliases_on_measuring_unit_id"

  create_table "measurement_conversions", :force => true do |t|
    t.integer  "smaller_measuring_unit_id"
    t.integer  "larger_measuring_unit_id"
    t.float    "multiplier"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "measurement_conversions", ["smaller_measuring_unit_id", "larger_measuring_unit_id"], :name => "conversion_units_index", :unique => true

  create_table "measuring_units", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "can_delete"
  end

  create_table "prep_orders", :force => true do |t|
    t.string   "name"
    t.integer  "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "prep_orders", ["order", "name"], :name => "index_prep_orders_on_order_and_name"

  create_table "recipe_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recipes", :force => true do |t|
    t.string   "name"
    t.integer  "recipe_type_id"
    t.integer  "servings"
    t.integer  "meals"
    t.string   "label_instructions"
    t.integer  "prep_order_id"
    t.text     "prep_instructions"
    t.text     "cooking_instructions"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
