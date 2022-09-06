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

ActiveRecord::Schema.define(:version => 20151202202913) do

  create_table "activities", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "activity_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "metadata"
    t.integer  "job_id"
    t.string   "user_name"
  end

  add_index "activities", ["company_id"], :name => "index_activities_on_company_id"
  add_index "activities", ["job_id"], :name => "index_activities_on_job_id"
  add_index "activities", ["target_id", "target_type"], :name => "index_activities_on_target_id_and_target_type"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "alerts", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "alert_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "job_id"
    t.integer  "created_by_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "expiration"
  end

  add_index "alerts", ["company_id"], :name => "index_alerts_on_company_id"
  add_index "alerts", ["created_by_id"], :name => "index_alerts_on_created_by"
  add_index "alerts", ["job_id"], :name => "index_alerts_on_job_id"
  add_index "alerts", ["target_id", "target_type"], :name => "index_alerts_on_target_id_and_target_type"
  add_index "alerts", ["user_id"], :name => "index_alerts_on_user_id"

  create_table "annotation_comments", :force => true do |t|
    t.integer  "company_id"
    t.integer  "annotation_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "annotation_comments", ["company_id"], :name => "index_annotation_comments_on_company_id"

  create_table "annotations", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal  "start_depth"
    t.decimal  "end_depth"
    t.integer  "event_warning_id"
    t.integer  "company_feature_id"
    t.string   "title"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "annotations", ["company_id"], :name => "index_annotations_on_company_id"
  add_index "annotations", ["job_id"], :name => "index_annotations_on_job_id"

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "asset_activities", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "part_id"
    t.integer  "activity_type"
    t.string   "description"
    t.string   "user_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "target_type"
    t.integer  "target_id"
  end

  add_index "asset_activities", ["company_id"], :name => "index_asset_activities_on_company_id"
  add_index "asset_activities", ["part_id"], :name => "index_asset_activities_on_part_id"

  create_table "asset_list_entries", :force => true do |t|
    t.integer  "company_id"
    t.integer  "asset_list_id"
    t.integer  "user_id"
    t.integer  "quantity"
    t.string   "description"
    t.decimal  "inner_diameter"
    t.decimal  "outer_diameter"
    t.decimal  "length"
    t.integer  "up"
    t.integer  "down"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "asset_list_entries", ["asset_list_id"], :name => "index_asset_list_entries_on_asset_list_id"
  add_index "asset_list_entries", ["company_id"], :name => "index_asset_list_entries_on_company_id"

  create_table "asset_lists", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "asset_lists", ["company_id"], :name => "index_asset_lists_on_company_id"
  add_index "asset_lists", ["job_id"], :name => "index_asset_lists_on_job_id"

  create_table "bha_items", :force => true do |t|
    t.integer  "company_id"
    t.integer  "bha_id"
    t.integer  "tool_id"
    t.decimal  "inner_diameter"
    t.decimal  "outer_diameter"
    t.decimal  "length"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "ordering"
    t.integer  "up"
    t.integer  "down"
    t.integer  "asset_type"
  end

  add_index "bha_items", ["bha_id"], :name => "index_bha_items_on_bha_id"
  add_index "bha_items", ["company_id"], :name => "index_bha_items_on_company_id"

  create_table "bhas", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "document_id"
    t.string   "name"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "description"
    t.decimal  "below_rotary"
    t.decimal  "above_rotary"
    t.decimal  "bit_to_sensor"
    t.decimal  "bit_to_gamma"
    t.integer  "bit_type"
    t.string   "bit_jets"
    t.decimal  "bit_tfa"
    t.decimal  "bit_size"
    t.integer  "master_bha_id"
    t.decimal  "total_circulation", :default => 0.0
  end

  add_index "bhas", ["company_id"], :name => "index_bhas_on_company_id"
  add_index "bhas", ["document_id"], :name => "index_bhas_on_document_id"

  create_table "bits", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.float    "size"
    t.string   "make"
    t.string   "jets"
    t.float    "tfa"
    t.float    "jets_velocity"
    t.float    "jet_impact_force"
    t.float    "hhsi"
    t.string   "serial_no"
    t.datetime "entry_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "default",          :default => false, :null => false
    t.integer  "number"
    t.float    "in_depth"
    t.float    "nozzle_size"
    t.integer  "bit_number"
    t.float    "depth_from"
    t.float    "depth_to"
  end

  add_index "bits", ["company_id"], :name => "index_bits_on_company_id"
  add_index "bits", ["entry_at"], :name => "index_bits_on_entry_at"
  add_index "bits", ["job_id"], :name => "index_bits_on_job_id"

  create_table "casings", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.float    "inner_diameter"
    t.float    "length"
    t.datetime "entry_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "default",        :default => false, :null => false
    t.float    "depth_from"
    t.float    "depth_to"
    t.float    "weight"
    t.string   "grade"
  end

  add_index "casings", ["company_id"], :name => "index_casings_on_company_id"
  add_index "casings", ["entry_at"], :name => "index_casings_on_entry_at"
  add_index "casings", ["job_id"], :name => "index_casings_on_job_id"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "country_id"
  end

  add_index "clients", ["company_id"], :name => "index_clients_on_company_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "support_email"
    t.string   "phone_number"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "postal_code"
    t.string   "state"
    t.string   "country"
    t.integer  "admin_id"
    t.string   "logo"
    t.string   "logo_large"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "vpn_range"
    t.boolean  "test_company",          :default => false
    t.boolean  "inventory_active",      :default => true
    t.string   "city"
    t.integer  "minimum_work_day",      :default => 8
    t.integer  "work_day_type",         :default => 1
    t.string   "operator_number"
    t.string   "railroad_signer"
    t.string   "railroad_signer_title"
    t.integer  "payroll_schedule",      :default => 1
    t.integer  "company_unit",          :default => 0
  end

  add_index "companies", ["name"], :name => "index_companies_on_name", :unique => true

  create_table "company_features", :force => true do |t|
    t.integer  "company_id"
    t.integer  "feature"
    t.boolean  "enabled"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "company_features", ["company_id"], :name => "index_company_features_on_company_id"

  create_table "conversation_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "conversation_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "company_id"
    t.boolean  "deleted",         :default => false
  end

  add_index "conversation_memberships", ["company_id"], :name => "index_conversation_memberships_on_company_id"
  add_index "conversation_memberships", ["conversation_id"], :name => "index_conversation_memberships_on_conversation_id"
  add_index "conversation_memberships", ["user_id", "conversation_id"], :name => "index_conversation_memberships_on_user_id_and_conversation_id"
  add_index "conversation_memberships", ["user_id"], :name => "index_conversation_memberships_on_user_id"

  create_table "conversations", :force => true do |t|
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "conversations", ["company_id"], :name => "index_conversations_on_company_id"

  create_table "countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "csv_mappings", :force => true do |t|
    t.string "column_from"
    t.string "column_to"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "location"
    t.integer  "country_id"
    t.integer  "state_id"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "city"
    t.string   "region"
    t.string   "support_email"
    t.string   "time_zone"
    t.integer  "master_district_id"
    t.boolean  "master",             :default => true
  end

  add_index "districts", ["company_id"], :name => "index_districts_on_company_id"
  add_index "districts", ["country_id"], :name => "index_districts_on_country_id"
  add_index "districts", ["master_district_id"], :name => "index_districts_on_master_district_id"
  add_index "districts", ["state_id"], :name => "index_districts_on_state_id"

  create_table "divisions", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "divisions", ["company_id"], :name => "index_divisions_on_company_id"

  create_table "document_revisions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "url"
    t.datetime "upload_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "document_revisions", ["company_id"], :name => "index_document_revisions_on_company_id"

  create_table "document_shares", :force => true do |t|
    t.integer  "document_id"
    t.string   "email"
    t.string   "access_code"
    t.integer  "shared_by_id"
    t.integer  "job_id"
    t.integer  "forwarded_document_share"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "company_id"
  end

  add_index "document_shares", ["company_id"], :name => "index_document_shares_on_company_id"
  add_index "document_shares", ["document_id", "email"], :name => "index_document_shares_on_document_id_and_email", :unique => true
  add_index "document_shares", ["document_id"], :name => "index_document_shares_on_document_id"
  add_index "document_shares", ["email"], :name => "index_document_shares_on_email"
  add_index "document_shares", ["forwarded_document_share"], :name => "index_document_shares_on_forwarded_document_share"
  add_index "document_shares", ["job_id"], :name => "index_document_shares_on_job_id"

  create_table "documents", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.string   "category"
    t.string   "name"
    t.string   "url"
    t.string   "status"
    t.boolean  "template",              :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "document_type",         :default => 0
    t.integer  "company_id"
    t.integer  "document_template_id"
    t.integer  "user_id"
    t.boolean  "read_only",             :default => false
    t.integer  "ordering",              :default => 0
    t.integer  "post_job_report_order"
    t.string   "user_name"
    t.integer  "primary_tool_id"
    t.integer  "access_level",          :default => 0
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "documents", ["company_id"], :name => "index_documents_on_company_id"
  add_index "documents", ["document_template_id"], :name => "index_documents_on_document_template_id"
  add_index "documents", ["job_id"], :name => "index_documents_on_job_id"
  add_index "documents", ["job_template_id"], :name => "index_documents_on_job_template_id"
  add_index "documents", ["owner_id", "owner_type"], :name => "index_documents_on_owner_id_and_owner_type"
  add_index "documents", ["primary_tool_id"], :name => "index_documents_on_primary_tool_id"

  create_table "drilling_log_entries", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.datetime "entry_at"
    t.decimal  "depth"
    t.integer  "activity_code"
    t.string   "comment",         :limit => 2500
    t.integer  "bha_id"
    t.decimal  "usage_hours"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "drilling_log_id"
    t.decimal  "hours",                           :default => 0.0
    t.datetime "end_time"
    t.boolean  "additional"
  end

  add_index "drilling_log_entries", ["bha_id"], :name => "index_drilling_log_entries_on_bha_id"
  add_index "drilling_log_entries", ["company_id"], :name => "index_drilling_log_entries_on_company_id"
  add_index "drilling_log_entries", ["document_id"], :name => "index_drilling_log_entries_on_document_id"
  add_index "drilling_log_entries", ["drilling_log_id"], :name => "index_drilling_log_entries_on_drilling_log_id"
  add_index "drilling_log_entries", ["job_id"], :name => "index_drilling_log_entries_on_job_id"
  add_index "drilling_log_entries", ["user_id"], :name => "index_drilling_log_entries_on_user_id"

  create_table "drilling_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.decimal  "rop"
    t.decimal  "total_drilled"
    t.decimal  "below_rotary"
    t.decimal  "slide_rop"
    t.decimal  "slide_footage"
    t.decimal  "slide_hours"
    t.decimal  "rotate_rop"
    t.decimal  "rotate_footage"
    t.decimal  "rotate_hours"
    t.decimal  "circulation_hours"
    t.decimal  "ream_hours"
    t.decimal  "rotary_hours_pct"
    t.decimal  "slide_hours_pct"
    t.decimal  "rotary_footage_pct"
    t.decimal  "slide_footage_pct"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.decimal  "above_rotary"
    t.decimal  "drilling_time"
    t.decimal  "total_circulation_time"
    t.decimal  "max_depth",              :default => 0.0
    t.decimal  "td_depth",               :default => 0.0
    t.decimal  "drilling_rop",           :default => 0.0
    t.decimal  "npt",                    :default => 0.0
    t.decimal  "total_time"
    t.integer  "well_id"
  end

  add_index "drilling_logs", ["company_id"], :name => "index_drilling_logs_on_company_id"
  add_index "drilling_logs", ["document_id"], :name => "index_drilling_logs_on_document_id"
  add_index "drilling_logs", ["job_id"], :name => "index_drilling_logs_on_job_id"

  create_table "drilling_properties", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "document_id"
    t.decimal  "wob"
    t.decimal  "rot_wt"
    t.decimal  "pu_wt"
    t.decimal  "so_wt"
    t.decimal  "spp"
    t.decimal  "flow"
    t.decimal  "spm"
    t.decimal  "rot_rpm"
    t.decimal  "mot_rpm"
    t.decimal  "incl_in"
    t.decimal  "azm_in"
    t.decimal  "incl_out"
    t.decimal  "azm_out"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "drilling_properties", ["document_id"], :name => "index_drilling_properties_on_document_id"

  create_table "drilling_strings", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.string   "type"
    t.float    "outer_diameter"
    t.float    "inner_diameter"
    t.float    "weight"
    t.float    "length"
    t.datetime "entry_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "default",        :default => false, :null => false
    t.integer  "position"
    t.float    "depth_from"
    t.float    "depth_to"
  end

  add_index "drilling_strings", ["company_id"], :name => "index_drilling_strings_on_company_id"
  add_index "drilling_strings", ["entry_at"], :name => "index_drilling_strings_on_entry_at"
  add_index "drilling_strings", ["job_id"], :name => "index_drilling_strings_on_job_id"

  create_table "dynamic_fields", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.string   "name",                                         :null => false
    t.string   "value"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "template"
    t.integer  "company_id"
    t.boolean  "priority"
    t.integer  "dynamic_field_template_id"
    t.integer  "value_type",                :default => 1
    t.integer  "default_value_type",        :default => 0
    t.integer  "ordering",                  :default => 0
    t.boolean  "predefined",                :default => false
    t.boolean  "optional",                  :default => false
    t.string   "values"
  end

  add_index "dynamic_fields", ["company_id"], :name => "index_dynamic_fields_on_company_id"
  add_index "dynamic_fields", ["dynamic_field_template_id"], :name => "index_dynamic_fields_on_dynamic_field_template_id"
  add_index "dynamic_fields", ["job_id"], :name => "index_dynamic_fields_on_job_id"
  add_index "dynamic_fields", ["job_template_id"], :name => "index_dynamic_fields_on_job_template_id"
  add_index "dynamic_fields", ["name"], :name => "index_dynamic_fields_on_name"

  create_table "event_warning_types", :force => true do |t|
    t.string   "name"
    t.string   "severity"
    t.string   "category"
    t.text     "description"
    t.text     "resolution"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "warning_id"
  end

  create_table "event_warnings", :force => true do |t|
    t.datetime "opened_at"
    t.datetime "closed_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "job_id"
    t.integer  "company_id"
    t.float    "depth_from"
    t.float    "depth_to"
    t.string   "event_warning_type_id"
    t.integer  "activity_id"
    t.text     "info"
  end

  add_index "event_warnings", ["company_id"], :name => "index_event_warnings_on_company_id"
  add_index "event_warnings", ["event_warning_type_id"], :name => "index_event_warnings_on_event_warning_type_id"
  add_index "event_warnings", ["job_id"], :name => "index_event_warnings_on_job_id"

  create_table "failures", :force => true do |t|
    t.string   "text"
    t.integer  "company_id"
    t.string   "reference"
    t.integer  "product_line_id"
    t.integer  "job_template_id"
    t.integer  "job_id"
    t.boolean  "template",                   :default => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "failure_master_template_id"
  end

  add_index "failures", ["company_id"], :name => "index_failures_on_company_id"
  add_index "failures", ["failure_master_template_id"], :name => "index_failures_on_failure_template_id"
  add_index "failures", ["job_id"], :name => "index_failures_on_job_id"
  add_index "failures", ["job_template_id"], :name => "index_failures_on_job_template_id"
  add_index "failures", ["product_line_id"], :name => "index_failures_on_product_line_id"

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "district_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "location"
    t.string   "county"
    t.integer  "country_id"
    t.integer  "state_id"
  end

  add_index "fields", ["company_id"], :name => "index_fields_on_company_id"
  add_index "fields", ["district_id"], :name => "index_fields_on_district_id"

  create_table "fluids", :force => true do |t|
    t.string   "type"
    t.float    "density"
    t.float    "funnel_viscosity"
    t.float    "filtrate"
    t.float    "ph"
    t.float    "mud_cake_thickness"
    t.float    "high_gravity_densities"
    t.float    "low_gravity_densities"
    t.float    "high_gravity_volume"
    t.float    "low_gravity_volume"
    t.float    "drilled_solids_volume"
    t.float    "rpm600"
    t.float    "rpm300"
    t.float    "rpm200"
    t.float    "rpm100"
    t.float    "rpm6"
    t.float    "rpm3"
    t.float    "seconds10"
    t.float    "minutes10"
    t.float    "water_volume"
    t.float    "oil_volume"
    t.float    "solid_volume"
    t.float    "methylene_blue"
    t.float    "drilling_fluid"
    t.float    "bentonite"
    t.float    "total_cl"
    t.float    "k_acetate"
    t.float    "potassium_bromide"
    t.float    "sodium_bromide"
    t.float    "calcium_bromide"
    t.float    "potassium_formate"
    t.float    "sodium_formate"
    t.float    "cesium_formate"
    t.float    "ammonium_chloride"
    t.float    "kci"
    t.float    "k2so4"
    t.float    "cacl2"
    t.float    "mgcl2"
    t.float    "brine_density"
    t.datetime "entry_at"
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "default",                :default => false, :null => false
    t.float    "pv"
    t.float    "yp"
    t.float    "in_depth"
  end

  add_index "fluids", ["company_id"], :name => "index_fluids_on_company_id"
  add_index "fluids", ["entry_at"], :name => "index_fluids_on_entry_at"
  add_index "fluids", ["job_id"], :name => "index_fluids_on_job_id"

  create_table "full_actual_tads", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "entry_at"
    t.string   "file_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "full_actual_tads", ["company_id"], :name => "index_full_actual_tads_on_company_id"
  add_index "full_actual_tads", ["job_id"], :name => "index_full_actual_tads_on_job_id"

  create_table "hole_sizes", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.float    "diameter"
    t.float    "depth"
    t.datetime "entry_at"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "default",    :default => false, :null => false
  end

  add_index "hole_sizes", ["company_id"], :name => "index_hole_sizes_on_company_id"
  add_index "hole_sizes", ["entry_at"], :name => "index_hole_sizes_on_entry_at"
  add_index "hole_sizes", ["job_id"], :name => "index_hole_sizes_on_job_id"

  create_table "import_history", :force => true do |t|
    t.integer "job_id"
    t.string  "filename"
  end

  create_table "issues", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "failure_id"
    t.integer  "status"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.datetime "failure_at"
    t.integer  "part_id"
    t.string   "part_serial_number"
    t.integer  "responsible_by_id"
    t.string   "responsible_by_name"
    t.boolean  "accountable",         :default => true
  end

  add_index "issues", ["company_id"], :name => "index_issues_on_company_id"
  add_index "issues", ["failure_id"], :name => "index_issues_on_failure_id"
  add_index "issues", ["job_id"], :name => "index_issues_on_job_id"

  create_table "job_costs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.decimal  "quantity",    :default => 0.0
    t.string   "description"
    t.integer  "charge_type"
    t.decimal  "price",       :default => 0.0
    t.datetime "charge_at"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "imported"
  end

  add_index "job_costs", ["company_id"], :name => "index_job_costs_on_company_id"
  add_index "job_costs", ["job_id"], :name => "index_job_costs_on_job_id"

  create_table "job_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "comment",     :limit => 500
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "entry_at"
    t.string   "user_name"
  end

  add_index "job_logs", ["company_id"], :name => "index_job_logs_on_company_id"
  add_index "job_logs", ["document_id"], :name => "index_job_logs_on_document_id"
  add_index "job_logs", ["job_id"], :name => "index_job_logs_on_job_id"
  add_index "job_logs", ["user_id"], :name => "index_job_logs_on_user_id"

  create_table "job_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "job_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "job_role_id"
    t.string   "user_name"
    t.integer  "company_id"
    t.string   "phone_number"
    t.string   "email"
    t.boolean  "external_user", :default => false
    t.integer  "shift_type"
  end

  add_index "job_memberships", ["company_id"], :name => "index_job_memberships_on_company_id"
  add_index "job_memberships", ["job_id"], :name => "index_job_memberships_on_job_id"
  add_index "job_memberships", ["user_id"], :name => "index_job_memberships_on_user_id"

  create_table "job_note_comments", :force => true do |t|
    t.integer  "job_id"
    t.integer  "job_note_id"
    t.integer  "user_id"
    t.string   "text",        :limit => 1000
    t.integer  "company_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "user_name"
  end

  add_index "job_note_comments", ["company_id"], :name => "index_job_note_comments_on_company_id"
  add_index "job_note_comments", ["job_id"], :name => "index_job_note_comments_on_job_id"
  add_index "job_note_comments", ["job_note_id"], :name => "index_job_note_comments_on_job_note_id"
  add_index "job_note_comments", ["user_id"], :name => "index_job_note_comments_on_user_id"

  create_table "job_notes", :force => true do |t|
    t.integer  "job_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "text",         :limit => 2000
    t.integer  "note_type"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "assign_to_id"
    t.string   "user_name"
    t.integer  "issue_id"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "job_notes", ["company_id"], :name => "index_job_notes_on_company_id"
  add_index "job_notes", ["owner_id", "owner_type"], :name => "index_job_notes_on_owner_id_and_owner_type"

  create_table "job_templates", :force => true do |t|
    t.string   "name"
    t.integer  "product_line_id"
    t.integer  "company_id"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "description",       :limit => 2000
    t.boolean  "track_accessories",                 :default => false
  end

  add_index "job_templates", ["company_id"], :name => "index_job_templates_on_company_id"
  add_index "job_templates", ["product_line_id"], :name => "index_job_templates_on_product_line_id"

  create_table "job_times", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.datetime "time_for"
    t.integer  "status"
    t.decimal  "hours"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "job_times", ["company_id"], :name => "index_job_times_on_company_id"
  add_index "job_times", ["job_id"], :name => "index_job_times_on_job_id"
  add_index "job_times", ["user_id"], :name => "index_job_times_on_user_id"

  create_table "jobs", :force => true do |t|
    t.integer  "job_template_id"
    t.integer  "field_id"
    t.integer  "well_id"
    t.integer  "district_id"
    t.integer  "client_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "company_id"
    t.integer  "status"
    t.datetime "close_date"
    t.integer  "rating"
    t.integer  "failures_count",                                 :default => 0
    t.integer  "job_memberships_count",                          :default => 0
    t.string   "job_number"
    t.string   "inventory_notes",                 :limit => 500
    t.boolean  "inventory_confirmed",                            :default => false
    t.string   "api_number"
    t.decimal  "total_cost",                                     :default => 0.0
    t.decimal  "proposed_cost",                                  :default => 0.0
    t.boolean  "shared",                                         :default => true
    t.integer  "drilling_company_id"
    t.integer  "directional_drilling_company_id"
    t.integer  "fluids_company_id"
    t.float    "perfect_well_ratio"
    t.datetime "section_last_entry_processed"
    t.float    "section_intermediate_start"
    t.float    "section_curve_start"
    t.float    "section_tangent_start"
    t.float    "section_drop_start"
    t.float    "horizontal_deviation",                           :default => 0.0
    t.integer  "time_step",                                      :default => 1
  end

  add_index "jobs", ["client_id"], :name => "index_jobs_on_client_id"
  add_index "jobs", ["company_id"], :name => "index_jobs_on_company_id"
  add_index "jobs", ["district_id"], :name => "index_jobs_on_district_id"
  add_index "jobs", ["field_id"], :name => "index_jobs_on_field_id"
  add_index "jobs", ["job_template_id"], :name => "index_jobs_on_job_template_id"
  add_index "jobs", ["well_id"], :name => "index_jobs_on_well_id"

  create_table "lwd_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.float    "depth"
    t.float    "GRAPI"
    t.float    "RHOB"
    t.float    "NPHI"
    t.float    "DTCO"
    t.float    "DTSM"
    t.float    "HDMI"
    t.float    "HDMX"
    t.float    "pore_pressure"
    t.float    "UCS"
    t.float    "YM"
    t.float    "LOT"
    t.float    "Minifrac"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.float    "emw_pore_pressure"
    t.float    "emw_shear_failure"
    t.float    "emw_min_stress"
    t.float    "emw_fracture_pressure"
  end

  add_index "lwd_logs", ["company_id"], :name => "index_lwd_logs_on_company_id"
  add_index "lwd_logs", ["job_id"], :name => "index_lwd_logs_on_job_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "company_id"
  end

  add_index "messages", ["company_id"], :name => "index_messages_on_company_id"
  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "mud_records", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "document_id"
    t.string   "type"
    t.decimal  "weight"
    t.decimal  "visc"
    t.decimal  "chlorides"
    t.decimal  "yp"
    t.decimal  "pv"
    t.decimal  "ph"
    t.decimal  "gas"
    t.decimal  "sand"
    t.decimal  "wl"
    t.decimal  "solid"
    t.decimal  "bht"
    t.decimal  "flow_t"
    t.decimal  "oil"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mud_records", ["document_id"], :name => "index_mud_records_on_document_id"

  create_table "note_activity_reports", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.string   "past"
    t.string   "present"
    t.string   "future"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "job_note_id"
  end

  add_index "note_activity_reports", ["company_id"], :name => "index_note_activity_reports_on_company_id"
  add_index "note_activity_reports", ["job_id"], :name => "index_note_activity_reports_on_job_id"
  add_index "note_activity_reports", ["job_note_id"], :name => "index_note_activity_reports_on_job_note_id"

  create_table "part_memberships", :force => true do |t|
    t.integer  "primary_tool_id"
    t.string   "material_number",        :limit => 30
    t.integer  "job_id"
    t.integer  "part_id"
    t.boolean  "template",                             :default => true
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "company_id"
    t.boolean  "track_usage"
    t.float    "usage"
    t.boolean  "optional",                             :default => false
    t.string   "name"
    t.string   "serial_number"
    t.boolean  "received",                             :default => false
    t.datetime "received_at"
    t.integer  "received_by"
    t.integer  "part_type"
    t.decimal  "inner_diameter"
    t.decimal  "outer_diameter"
    t.decimal  "length"
    t.boolean  "shipping",                             :default => false
    t.integer  "shipment_id"
    t.integer  "job_part_membership_id"
    t.integer  "supplier_id"
    t.integer  "up"
    t.integer  "down"
    t.integer  "from_id"
    t.string   "from_type"
    t.integer  "to_id"
    t.string   "to_type"
    t.string   "from_name"
    t.string   "to_name"
    t.integer  "asset_type",                           :default => 0
    t.integer  "charge_type"
    t.decimal  "price"
  end

  add_index "part_memberships", ["company_id"], :name => "index_part_memberships_on_company_id"
  add_index "part_memberships", ["job_id"], :name => "index_part_memberships_on_job_id"
  add_index "part_memberships", ["material_number"], :name => "index_part_memberships_on_material_number"
  add_index "part_memberships", ["primary_tool_id"], :name => "index_part_memberships_on_primary_tool_id"
  add_index "part_memberships", ["shipment_id"], :name => "index_part_memberships_on_shipment_id"

  create_table "part_redresses", :force => true do |t|
    t.integer  "company_id"
    t.integer  "part_id"
    t.integer  "job_id"
    t.string   "notes"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.datetime "received_at"
    t.datetime "finished_redress_at"
    t.integer  "received_by_id"
    t.integer  "finished_redress_by_id"
    t.string   "received_by_name"
    t.string   "finished_redress_by_name"
    t.boolean  "no_redress",               :default => false
  end

  add_index "part_redresses", ["company_id"], :name => "index_part_redresses_on_company_id"
  add_index "part_redresses", ["job_id"], :name => "index_part_redresses_on_job_id"
  add_index "part_redresses", ["part_id"], :name => "index_part_redresses_on_part_id"

  create_table "parts", :force => true do |t|
    t.string   "name"
    t.string   "part_number"
    t.boolean  "template",                             :default => false
    t.integer  "master_part_id"
    t.integer  "status"
    t.integer  "current_job_id"
    t.integer  "primary_tool_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "district_id"
    t.boolean  "active",                               :default => true
    t.string   "material_number",        :limit => 30
    t.string   "serial_number",          :limit => 30
    t.string   "district_serial_number", :limit => 30
    t.integer  "total_count",                          :default => 0
    t.integer  "on_hand_count",                        :default => 0
    t.string   "location"
    t.integer  "total_uses",                           :default => 0
    t.integer  "company_id"
    t.integer  "warehouse_id"
    t.decimal  "below_rotary"
    t.decimal  "above_rotary"
    t.integer  "current_shipment_id"
    t.string   "category"
    t.string   "manufacturer"
    t.decimal  "max_hours"
    t.decimal  "weight"
    t.boolean  "rental",                               :default => false
    t.integer  "asset_type",                           :default => 0
    t.integer  "supplier_id"
    t.decimal  "total_circulation",                    :default => 0.0
    t.boolean  "container",                            :default => false
    t.integer  "container_id"
  end

  add_index "parts", ["company_id"], :name => "index_parts_on_company_id"
  add_index "parts", ["district_id"], :name => "index_parts_on_district_id"
  add_index "parts", ["district_serial_number"], :name => "index_parts_on_district_serial_number"
  add_index "parts", ["material_number"], :name => "index_parts_on_material_number"
  add_index "parts", ["part_number"], :name => "index_parts_on_part_number"
  add_index "parts", ["serial_number"], :name => "index_parts_on_serial_number"

  create_table "post_job_report_documents", :force => true do |t|
    t.integer  "document_id"
    t.integer  "job_template_id"
    t.integer  "ordering"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "company_id"
  end

  add_index "post_job_report_documents", ["document_id"], :name => "index_post_job_report_documents_on_document_id"
  add_index "post_job_report_documents", ["job_template_id"], :name => "index_post_job_report_documents_on_job_template_id"

  create_table "primary_tools", :force => true do |t|
    t.integer  "tool_id"
    t.integer  "job_template_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "company_id"
    t.integer  "job_id"
    t.string   "comments"
    t.boolean  "template",        :default => true
    t.string   "serial_number"
    t.boolean  "received",        :default => false
    t.boolean  "simple_tracking", :default => false
  end

  add_index "primary_tools", ["job_template_id"], :name => "index_primary_tools_on_job_template_id"
  add_index "primary_tools", ["tool_id"], :name => "index_primary_tools_on_tool_id"

  create_table "product_lines", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "segment_id"
  end

  add_index "product_lines", ["company_id"], :name => "index_product_lines_on_company_id"

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "company_id"
    t.text     "histogram"
  end

  create_table "programs_wells", :id => false, :force => true do |t|
    t.integer "program_id"
    t.integer "well_id"
  end

  create_table "rig_memberships", :force => true do |t|
    t.integer  "company_id"
    t.integer  "crew_id"
    t.integer  "user_id"
    t.string   "user_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "rig_id"
  end

  add_index "rig_memberships", ["company_id"], :name => "index_rig_memberships_on_company_id"
  add_index "rig_memberships", ["rig_id"], :name => "index_rig_memberships_on_rig_id"
  add_index "rig_memberships", ["user_id", "rig_id"], :name => "index_rig_memberships_on_user_id_and_rig_id", :unique => true
  add_index "rig_memberships", ["user_id"], :name => "index_crew_memberships_on_user_id"

  create_table "rigs", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.integer  "rig_memberships_count",             :default => 0
    t.integer  "benchmark_wtw",                     :default => 350
    t.integer  "benchmark_connection",              :default => 80
    t.integer  "benchmark_treatment",               :default => 230
    t.integer  "benchmark_bottom",                  :default => 1400
    t.integer  "benchmark_tripping_in_connection",  :default => 40
    t.integer  "benchmark_tripping_in_pipe",        :default => 30
    t.integer  "benchmark_tripping_out_connection", :default => 40
    t.integer  "benchmark_tripping_out_pipe",       :default => 20
    t.integer  "program_id"
    t.integer  "offset_well_id"
    t.float    "day_cost"
    t.text     "histogram"
    t.decimal  "block_weight"
  end

  add_index "rigs", ["company_id"], :name => "index_rigs_on_company_id"

  create_table "secondary_tools", :force => true do |t|
    t.integer  "tool_id"
    t.integer  "job_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "company_id"
    t.string   "serial_number"
    t.boolean  "received",      :default => false
  end

  add_index "secondary_tools", ["job_id"], :name => "index_secondary_tools_on_job_id"
  add_index "secondary_tools", ["tool_id"], :name => "index_secondary_tools_on_tool_id"

  create_table "segments", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "division_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "segments", ["company_id"], :name => "index_segments_on_company_id"
  add_index "segments", ["division_id"], :name => "index_segments_on_division_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipments", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "accepted_by_id"
    t.datetime "accepted_at"
    t.string   "from_type"
    t.string   "to_type"
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "status"
    t.integer  "district_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "from_name"
    t.string   "to_name"
    t.boolean  "from_editable"
    t.integer  "shipper_id"
    t.integer  "part_memberships_count"
  end

  add_index "shipments", ["company_id"], :name => "index_shipments_on_company_id"

  create_table "shippers", :force => true do |t|
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "name"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "shippers", ["company_id"], :name => "index_shippers_on_company_id"

  create_table "states", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "states", ["country_id"], :name => "index_states_on_country_id"

  create_table "suppliers", :force => true do |t|
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "name"
    t.string   "location"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "suppliers", ["company_id"], :name => "index_suppliers_on_company_id"

  create_table "survey_points", :force => true do |t|
    t.integer  "company_id"
    t.integer  "survey_id"
    t.decimal  "measured_depth"
    t.decimal  "inclination"
    t.decimal  "azimuth"
    t.boolean  "tie_on"
    t.decimal  "true_vertical_depth"
    t.decimal  "north_south"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.decimal  "east_west"
    t.string   "comment"
    t.decimal  "vertical_section"
    t.integer  "user_id"
    t.string   "user_name"
    t.decimal  "course_length"
    t.decimal  "dog_leg_severity"
    t.decimal  "closure_distance"
    t.decimal  "closure_angle"
    t.decimal  "magnetic_field_strength"
    t.decimal  "magnetic_dip_angle"
    t.decimal  "gravity_total"
  end

  add_index "survey_points", ["company_id"], :name => "index_survey_points_on_company_id"
  add_index "survey_points", ["survey_id"], :name => "index_survey_points_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.integer  "company_id"
    t.integer  "document_id"
    t.integer  "job_id"
    t.integer  "user_id"
    t.boolean  "plan"
    t.string   "name"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "north_type",               :default => 1
    t.decimal  "vertical_section_azimuth"
    t.decimal  "magnetic_field_strength"
    t.decimal  "magnetic_dip_angle"
    t.decimal  "gravity_total"
    t.string   "gyro_company"
    t.datetime "gyro_date"
    t.boolean  "no_well_plan",             :default => false
    t.decimal  "total_correction"
    t.integer  "grid_type",                :default => 1
    t.integer  "well_plan_for_survey_id"
  end

  add_index "surveys", ["company_id"], :name => "index_surveys_on_company_id"
  add_index "surveys", ["document_id"], :name => "index_surveys_on_document_id"
  add_index "surveys", ["job_id"], :name => "index_surveys_on_job_id"

  create_table "tools", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "division_id"
    t.integer  "product_line_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "description"
  end

  add_index "tools", ["company_id"], :name => "index_tools_on_company_id"
  add_index "tools", ["division_id"], :name => "index_tools_on_division_id"
  add_index "tools", ["product_line_id"], :name => "index_tools_on_product_line_id"

  create_table "torque_drag_charts", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "entry_at"
    t.string   "file_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "torque_drag_charts", ["company_id"], :name => "index_torque_drag_charts_on_company_id"
  add_index "torque_drag_charts", ["job_id"], :name => "index_torque_drag_charts_on_job_id"

  create_table "torque_drag_data", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.datetime "entry_at"
    t.string   "file_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "torque_drag_data", ["company_id"], :name => "index_torque_drag_data_on_company_id"
  add_index "torque_drag_data", ["job_id"], :name => "index_torque_drag_data_on_job_id"

  create_table "user_logins", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.string   "ip_address", :limit => 200
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "user_logins", ["company_id"], :name => "index_user_logins_on_company_id"
  add_index "user_logins", ["user_id"], :name => "index_user_logins_on_user_id"

  create_table "user_roles", :force => true do |t|
    t.string   "title"
    t.integer  "company_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "role_id"
  end

  add_index "user_roles", ["company_id"], :name => "index_user_roles_on_company_id"

  create_table "user_units", :force => true do |t|
    t.integer  "user_id"
    t.integer  "length_outer"
    t.integer  "length_inner"
    t.integer  "temperature"
    t.integer  "pressure"
    t.integer  "rate"
    t.integer  "volume"
    t.integer  "area"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "weight"
    t.integer  "weight_casing"
    t.integer  "weight_gradient"
    t.integer  "company_id"
    t.integer  "viscosity"
  end

  add_index "user_units", ["company_id"], :name => "index_user_units_on_company_id"
  add_index "user_units", ["user_id"], :name => "index_user_units_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin",                                  :default => false
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "location"
    t.string   "phone_number"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "password_digest"
    t.boolean  "elephant_admin",                         :default => false
    t.string   "remember_token"
    t.boolean  "create_password",                        :default => false
    t.integer  "role_id"
    t.integer  "product_line_id"
    t.string   "time_zone"
    t.string   "language"
    t.boolean  "send_daily_activity",                    :default => true
    t.boolean  "accepted_tou",                           :default => false
    t.string   "unverified_network"
    t.string   "network_access_code"
    t.string   "verified_networks",      :limit => 2000
    t.integer  "division_id"
    t.integer  "segment_id"
    t.integer  "invalid_login_attempts",                 :default => 0
    t.integer  "restricted_rig_id"
  end

  add_index "users", ["company_id"], :name => "index_users_on_company_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"
  add_index "users", ["restricted_rig_id"], :name => "index_users_on_restricted_rig_id"

  create_table "warehouse_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "warehouse_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "warehouse_memberships", ["company_id"], :name => "index_warehouse_memberships_on_company_id"
  add_index "warehouse_memberships", ["user_id", "warehouse_id"], :name => "index_warehouse_memberships_on_user_id_and_warehouse_id", :unique => true
  add_index "warehouse_memberships", ["user_id"], :name => "index_warehouse_memberships_on_user_id"
  add_index "warehouse_memberships", ["warehouse_id"], :name => "index_warehouse_memberships_on_warehouse_id"

  create_table "warehouses", :force => true do |t|
    t.integer  "company_id"
    t.integer  "district_id"
    t.string   "name"
    t.string   "location"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "email"
    t.string   "state"
  end

  add_index "warehouses", ["company_id"], :name => "index_warehouses_on_company_id"
  add_index "warehouses", ["district_id"], :name => "index_warehouses_on_district_id"

  create_table "wells", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "field_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "location",               :limit => 50
    t.string   "bottom_hole_location",   :limit => 50
    t.integer  "rig_id"
    t.integer  "offset_well_id"
    t.string   "county"
    t.string   "drilling_company"
    t.string   "fluid_company"
    t.string   "well_number"
    t.string   "api_number"
    t.float    "hole_depth"
    t.integer  "total_time"
    t.integer  "total_time_morning"
    t.integer  "total_time_night"
    t.float    "drilling_rop"
    t.float    "potential_savings"
    t.text     "histogram"
    t.datetime "finished_at"
    t.datetime "started_at"
    t.text     "warnings_by_depth"
    t.text     "depth_vs_time_logs"
    t.text     "depth_vs_warnings_logs"
    t.text     "footage_logs"
    t.text     "depth_vs_cost_logs"
    t.float    "rop"
    t.float    "drilling_time"
  end

  add_index "wells", ["company_id"], :name => "index_wells_on_company_id"
  add_index "wells", ["field_id"], :name => "index_wells_on_field_id"
  add_index "wells", ["offset_well_id"], :name => "index_wells_on_offset_well_id"

  create_table "wits_activity_lists", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "start_time"
    t.integer  "operation_time"
    t.string   "activity_name"
    t.datetime "end_time"
    t.float    "hole_depth"
    t.float    "hole_depth_change"
    t.float    "bit_depth"
    t.float    "bit_depth_change"
  end

  add_index "wits_activity_lists", ["company_id"], :name => "index_wits_activity_lists_on_company_id"
  add_index "wits_activity_lists", ["end_time"], :name => "index_wits_activity_lists_on_end_time"
  add_index "wits_activity_lists", ["job_id"], :name => "index_wits_activity_lists_on_job_id"
  add_index "wits_activity_lists", ["start_time"], :name => "index_wits_activity_lists_on_start_time"

  create_table "wits_category_allocs", :id => false, :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.float    "total_well_time"
    t.datetime "entry_at"
    t.float    "reaming_in_time"
    t.float    "reaming_out_time"
    t.float    "reaming_time"
    t.float    "wash_up_time"
    t.float    "wash_down_time"
    t.float    "washing_time"
    t.float    "circulation_time"
    t.float    "drilling_time"
    t.float    "connection_time"
    t.float    "tripping_out_time"
    t.float    "tripping_in_time"
    t.float    "out_of_hole_time"
    t.float    "other_time"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "wits_category_allocs", ["company_id"], :name => "index_wits_category_allocs_on_company_id"
  add_index "wits_category_allocs", ["entry_at"], :name => "index_wits_category_allocs_on_entry_at"
  add_index "wits_category_allocs", ["job_id"], :name => "index_wits_category_allocs_on_job_id"

  create_table "wits_category_data", :id => false, :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "entry_at"
    t.string   "category"
    t.integer  "op_count"
    t.float    "average"
    t.float    "duration"
    t.float    "potential"
    t.float    "p10"
    t.float    "p50"
    t.float    "p90"
  end

  add_index "wits_category_data", ["company_id"], :name => "index_wits_category_data_on_company_id"
  add_index "wits_category_data", ["entry_at"], :name => "index_wits_category_data_on_entry_at"
  add_index "wits_category_data", ["job_id"], :name => "index_wits_category_data_on_job_id"

  create_table "wits_category_histograms", :force => true do |t|
    t.integer  "job_id"
    t.integer  "category"
    t.float    "ten_per"
    t.float    "fifty_per"
    t.float    "ninety_per"
    t.integer  "op_count"
    t.float    "total_time"
    t.float    "total_category_time"
    t.float    "avg_time"
    t.float    "max_op_time"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "wits_category_histograms", ["job_id"], :name => "index_wits_category_histograms_on_job_id"

  create_table "wits_category_lists", :id => false, :force => true do |t|
    t.string   "time_index"
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "time_stamp"
    t.integer  "operation_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "category_name"
  end

  add_index "wits_category_lists", ["company_id"], :name => "index_wits_category_lists_on_company_id"
  add_index "wits_category_lists", ["job_id"], :name => "index_wits_category_lists_on_job_id"
  add_index "wits_category_lists", ["operation_time"], :name => "index_wits_category_lists_on_operation_time"
  add_index "wits_category_lists", ["time_stamp"], :name => "index_wits_category_lists_on_time_stamp"

  create_table "wits_data", :id => false, :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "entry_at"
    t.float    "hook_load"
    t.float    "rotary_torque"
    t.float    "rotary_rpm"
    t.float    "standpipe_pressure"
    t.float    "block_height"
    t.float    "bit_depth"
    t.float    "hole_depth"
    t.float    "weight_on_bit"
    t.float    "total_gas"
    t.float    "mud_flow_in"
    t.float    "mud_flow_out"
    t.float    "mud_temp_in"
    t.float    "mud_temp_out"
    t.float    "pump_spm_total"
    t.float    "gain_loss"
    t.float    "gamma_ray"
    t.float    "mud_volume"
    t.float    "strks_pump_1"
    t.float    "strks_pump_2"
    t.float    "strks_pump_3"
    t.float    "strks_total"
    t.float    "svy_azimuth"
    t.float    "svy_depth"
    t.float    "svy_inclination"
    t.float    "pump_spm_1"
    t.float    "pump_spm_2"
    t.float    "pump_spm_3"
    t.float    "pit_volume_1"
    t.float    "pit_volume_2"
    t.float    "pit_volume_3"
    t.float    "pit_volume_4"
    t.float    "pit_volume_5"
    t.float    "pit_volume_6"
    t.float    "pit_volume_7"
    t.float    "pit_volume_8"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "wits_data", ["company_id"], :name => "index_wits_data_on_company_id"
  add_index "wits_data", ["entry_at"], :name => "index_wits_data_on_entry_at"
  add_index "wits_data", ["job_id"], :name => "index_wits_data_on_job_id"

  create_table "wits_gactivities", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "activity"
    t.float    "hole_depth"
    t.float    "bit_depth"
  end

  add_index "wits_gactivities", ["company_id"], :name => "index_wits_gactivities_on_company_id"
  add_index "wits_gactivities", ["end_time"], :name => "index_wits_gactivities_on_end_time"
  add_index "wits_gactivities", ["job_id"], :name => "index_wits_gactivities_on_job_id"
  add_index "wits_gactivities", ["start_time"], :name => "index_wits_gactivities_on_start_time"

  create_table "wits_histogram_data", :force => true do |t|
    t.integer  "wits_histogram_id"
    t.float    "op_time"
    t.integer  "op_count"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "wits_histogram_data", ["wits_histogram_id"], :name => "index_wits_histogram_data_on_wits_histogram_id"

  create_table "wits_histograms", :force => true do |t|
    t.integer  "job_id"
    t.integer  "company_id"
    t.integer  "category"
    t.float    "ten_per"
    t.float    "fifty_per"
    t.float    "ninety_per"
    t.integer  "op_count"
    t.float    "total_time"
    t.float    "total_category_time"
    t.float    "avg_time"
    t.float    "max_op_time"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "wits_histograms", ["company_id"], :name => "index_wits_histograms_on_company_id"
  add_index "wits_histograms", ["job_id"], :name => "index_wits_histograms_on_job_id"

  create_table "wits_records", :force => true do |t|
    t.integer  "company_id"
    t.integer  "job_id"
    t.datetime "entry_at"
    t.float    "bit_depth"
    t.float    "hole_depth"
    t.float    "min_convertible_torque"
    t.float    "hook_load"
    t.float    "standpipe_pressure"
    t.float    "rotary_rpm"
    t.float    "rotary_torque"
    t.float    "weight_on_bit"
    t.float    "on_bottom_rop"
    t.float    "flow"
    t.float    "total_mud_volume"
    t.float    "trip_tank_mud_volume"
    t.float    "line_wear"
    t.float    "casing_pressure"
    t.float    "pump1_rate"
    t.float    "pump2_rate"
    t.float    "pump3_rate"
    t.float    "pump4_rate"
    t.float    "pump1_total_strokes"
    t.float    "pump2_total_strokes"
    t.float    "pump3_total_strokes"
    t.float    "pump4_total_strokes"
    t.float    "total_strokes"
    t.float    "total_pump_output"
    t.float    "total_pump_displacement"
    t.float    "block_height"
    t.float    "mud_tank1_volume"
    t.float    "mud_tank2_volume"
    t.float    "mud_tank3_volume"
    t.float    "mud_tank4_volume"
    t.float    "mud_tank5_volume"
    t.float    "on_bottom_hours"
    t.float    "circulating_hours"
    t.float    "explosive_gas1"
    t.float    "explosive_gas2"
    t.float    "tool_face"
    t.float    "inclination"
    t.float    "azimuth"
    t.float    "gamma"
    t.float    "mud_gl_alarm_state"
    t.float    "flow_1_gl_alarm_state"
    t.float    "magnetic_tool_face"
    t.float    "gravity_tool_face"
    t.float    "mwd_vibration_xyz"
    t.float    "mwd_temperature"
    t.float    "mwd_general_variable1"
    t.float    "mwd_general_variable2"
    t.float    "mwd_general_variable3"
    t.float    "mwd_general_variable4"
    t.float    "mwd_vibration_xyz_gamma"
    t.float    "mwd_vibration_xy_gamma"
    t.float    "mwd_vibration_z_gamma"
    t.float    "over_pull"
    t.float    "fill_strokes"
    t.float    "total_fill_strokes"
    t.float    "min_pressure"
    t.float    "min_hook_load"
    t.float    "min_torque"
    t.float    "min_rpm"
    t.float    "min_wob"
    t.float    "relative_mse"
    t.float    "cement_fluid_temp"
    t.float    "mwd_vibration_count"
    t.float    "sensor_depth"
    t.float    "pvt_total_mud_gain_loss"
    t.float    "differential_pressure"
    t.float    "pason_lag_depth"
    t.float    "tts_weight_on_bit"
    t.float    "drilling_activity"
    t.float    "min_tts_weight_on_bit"
    t.float    "choke_position"
    t.float    "trip_speed"
    t.float    "gamma_depth"
    t.float    "gamma_at_bit"
    t.float    "resistivity2"
    t.float    "formation_density"
    t.float    "res2_at_bit"
    t.float    "fdens_at_bit"
    t.float    "percent_wits_gas"
    t.float    "motor_rpm"
    t.float    "convertible_torque"
    t.float    "p1_rate"
    t.float    "p2_rate"
    t.float    "pvt_mud_tanks_included"
    t.float    "pvt_monitor_mud_gl"
    t.float    "pvt_mud_gl_threshold"
    t.float    "trip_tank_1_refill_status"
    t.float    "trip_tank_1_low_threshold"
    t.float    "trip_tank_1_high_threshold"
    t.float    "flow_1_gl"
    t.float    "flow_1_gl_threshold"
    t.float    "xy_accel_severity_level"
    t.float    "z_accel_severity_level"
    t.float    "trip_tank_fill"
    t.float    "trip_tank_accum"
    t.float    "rate_of_penetration"
    t.float    "time_of_penetration"
    t.float    "autodriller_status"
    t.float    "autodriller_sensitivity"
    t.float    "autodriller_drum_ticks"
    t.float    "autodriller_wob"
    t.float    "autodriller_wob_sp"
    t.float    "autodriller_brake_pos"
    t.float    "autodriller_diff_press"
    t.float    "autodriller_diff_press_sp"
    t.float    "autodriller_torque"
    t.float    "autodriller_torque_limit"
    t.float    "autodriller_status_uw"
    t.float    "autodriller_status_lw"
    t.float    "autodriller_status_2_uw"
    t.float    "autodriller_status_2_lw"
    t.float    "autodriller_timedrill_sp"
    t.float    "autodriller_rop_sp"
    t.float    "autodriller_ticks_per_depth"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "witsml_servers", :force => true do |t|
    t.integer  "company_id"
    t.string   "location"
    t.string   "encrypted_username"
    t.string   "encrypted_password"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "witsml_servers", ["company_id"], :name => "index_witsml_servers_on_company_id"

end
