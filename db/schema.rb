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

ActiveRecord::Schema.define(version: 2022_09_01_034826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.string "question_type"
    t.integer "question_id"
    t.string "value"
    t.text "array_value", array: true
    t.bigint "report_id"
    t.string "question_name"
    t.index ["report_id"], name: "index_answers_on_report_id"
  end

  create_table "check_box_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.bigint "check_box_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_box_id"], name: "index_check_box_option_strings_on_check_box_id"
  end

  create_table "check_boxes", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "check_box", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_check_boxes_on_question_id"
  end

  create_table "counseling_confirmers", force: :cascade do |t|
    t.integer "counseling_confirmer_id", null: false
    t.text "counseling_reply_detail"
    t.boolean "counseling_reply_flag", default: false, null: false
    t.boolean "counseling_confirmation_flag", default: false, null: false
    t.bigint "counseling_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["counseling_id"], name: "index_counseling_confirmers_on_counseling_id"
  end

  create_table "counselings", force: :cascade do |t|
    t.text "counseling_detail", default: "", null: false
    t.date "counseling_reply_deadline"
    t.bigint "project_id"
    t.integer "sender_id"
    t.string "sender_name"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_counselings_on_project_id"
  end

  create_table "date_fields", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "date_field", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_date_fields_on_question_id"
  end

  create_table "delegations", force: :cascade do |t|
    t.bigint "project_id"
    t.integer "user_from"
    t.integer "user_to"
    t.boolean "is_valid", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_delegations_on_project_id"
  end

  create_table "formats", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_formats_on_project_id"
  end

  create_table "joins", force: :cascade do |t|
    t.string "token"
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_confirmers", force: :cascade do |t|
    t.integer "message_confirmer_id", null: false
    t.boolean "message_confirmation_flag", default: false, null: false
    t.bigint "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_confirmers_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "message_detail", default: "", null: false
    t.bigint "project_id"
    t.integer "sender_id"
    t.string "sender_name"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_messages_on_project_id"
  end

  create_table "project_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_users_on_project_id"
    t.index ["user_id"], name: "index_project_users_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "leader_id", null: false
    t.integer "report_frequency", default: 1, null: false
    t.date "next_report_date", null: false
    t.boolean "reported_flag", default: false, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "position"
    t.string "form_table_type", default: "", null: false
    t.bigint "project_id"
    t.boolean "using_flag", default: true, null: false
    t.boolean "required", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_questions_on_project_id"
  end

  create_table "radio_button_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.bigint "radio_button_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["radio_button_id"], name: "index_radio_button_option_strings_on_radio_button_id"
  end

  create_table "radio_buttons", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "radio_button", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_radio_buttons_on_question_id"
  end

  create_table "report_confirmers", force: :cascade do |t|
    t.integer "report_confirmer_id", null: false
    t.boolean "report_confirmation_flag", default: false, null: false
    t.bigint "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_id"], name: "index_report_confirmers_on_report_id"
  end

  create_table "report_deadlines", force: :cascade do |t|
    t.date "day"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_report_deadlines_on_project_id"
  end

  create_table "report_statuses", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "has_submitted", default: false
    t.boolean "has_reminded", default: false
    t.date "deadline"
    t.boolean "is_newest", default: true
    t.index ["project_id"], name: "index_report_statuses_on_project_id"
    t.index ["user_id"], name: "index_report_statuses_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.boolean "remanded"
    t.string "remanded_reason"
    t.integer "sender_id"
    t.string "sender_name"
    t.string "title"
    t.date "report_day"
    t.boolean "resubmitted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_reports_on_project_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "select_option_strings", force: :cascade do |t|
    t.string "option_string", default: "", null: false
    t.bigint "select_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["select_id"], name: "index_select_option_strings_on_select_id"
  end

  create_table "selects", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "select", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_selects_on_question_id"
  end

  create_table "text_areas", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "text_area", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_text_areas_on_question_id"
  end

  create_table "text_fields", force: :cascade do |t|
    t.string "label_name", default: "", null: false
    t.string "field_type", default: "text_field", null: false
    t.bigint "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_text_fields_on_question_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "has_editted", default: true
    t.integer "invited_by"
    t.string "name", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.string "remember_token"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "reports"
  add_foreign_key "check_box_option_strings", "check_boxes"
  add_foreign_key "check_boxes", "questions"
  add_foreign_key "counseling_confirmers", "counselings"
  add_foreign_key "counselings", "projects"
  add_foreign_key "date_fields", "questions"
  add_foreign_key "delegations", "projects"
  add_foreign_key "formats", "projects"
  add_foreign_key "message_confirmers", "messages"
  add_foreign_key "messages", "projects"
  add_foreign_key "project_users", "projects"
  add_foreign_key "project_users", "users"
  add_foreign_key "questions", "projects"
  add_foreign_key "radio_button_option_strings", "radio_buttons"
  add_foreign_key "radio_buttons", "questions"
  add_foreign_key "report_confirmers", "reports"
  add_foreign_key "report_deadlines", "projects"
  add_foreign_key "report_statuses", "projects"
  add_foreign_key "report_statuses", "users"
  add_foreign_key "reports", "projects"
  add_foreign_key "reports", "users"
  add_foreign_key "select_option_strings", "selects"
  add_foreign_key "selects", "questions"
  add_foreign_key "text_areas", "questions"
  add_foreign_key "text_fields", "questions"
end
