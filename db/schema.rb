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

ActiveRecord::Schema.define(version: 20200711135335) do

  create_table "accident_invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "invoice_file_name"
    t.string "invoice_content_type"
    t.bigint "invoice_file_size"
    t.datetime "invoice_updated_at"
    t.string "invoice_number"
    t.string "vin"
    t.string "plate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_id"
    t.string "job_status"
    t.boolean "can_show_highlight", default: false
    t.integer "total_pages", default: 1
    t.string "text_job_id"
    t.string "text_job_status"
  end

  create_table "bounding_boxes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "geometry_block_id"
    t.string "top"
    t.string "left"
    t.string "width"
    t.string "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cell_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "table_entry_id"
    t.string "value"
    t.integer "row_index"
    t.integer "column_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geometry_blocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "entry_id"
    t.string "entry_type"
    t.string "entity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page"
  end

  create_table "key_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "invoice_id"
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "table_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "invoice_id"
    t.integer "row_count"
    t.integer "column_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "word_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "invoice_id"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
