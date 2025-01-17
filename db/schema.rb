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

ActiveRecord::Schema.define(:version => 20111012154731) do

  create_table "builds", :force => true do |t|
    t.integer  "project_id"
    t.text     "output"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author"
    t.string   "commit"
    t.string   "comment"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deploys", :force => true do |t|
    t.integer  "project_id"
    t.text     "output"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "branch",                :default => "master"
    t.string   "deploy_command",        :default => "rake inploy:remote:update"
    t.string   "build_command",         :default => "rake build"
    t.boolean  "building"
    t.boolean  "bundle_install",        :default => true
    t.boolean  "continuous_deployment", :default => false
  end

end
