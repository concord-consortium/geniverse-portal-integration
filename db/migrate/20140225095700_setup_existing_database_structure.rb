class SetupExistingDatabaseStructure < ActiveRecord::Migration
  def up
    create_table "geniverse_activities", :force => true do |t|
      t.text     "initial_alleles"
      t.string   "base_channel_name"
      t.integer  "max_users_in_room"
      t.boolean  "send_bred_dragons"
      t.string   "title"
      t.string   "hidden_genes"
      t.text     "static_genes"
      t.boolean  "crossover_when_breeding",    :default => false
      t.string   "route"
      t.string   "pageType"
      t.text     "message"
      t.text     "match_dragon_alleles"
      t.integer  "myCase_id"
      t.integer  "myCaseOrder"
      t.boolean  "is_argumentation_challenge", :default => false
      t.integer  "threshold_three_stars"
      t.integer  "threshold_two_stars"
      t.boolean  "show_color_labels"
      t.text     "congratulations"
      t.boolean  "show_tooltips",              :default => false

      t.timestamps
    end

    add_index "geniverse_activities", ["route"], :name => "index_activities_on_route"

    create_table "geniverse_articles", :force => true do |t|
      t.integer  "group"
      t.integer  "activity_id"
      t.text     "text"
      t.integer  "time"
      t.boolean  "submitted"
      t.text     "teacherComment"
      t.boolean  "accepted"

      t.timestamps
    end

    create_table "geniverse_cases", :force => true do |t|
      t.string   "name"
      t.integer  "order"
      t.string   "introImageUrl"

      t.timestamps
    end

    create_table "geniverse_dragons", :force => true do |t|
      t.string   "name"
      t.integer  "sex"
      t.string   "alleles"
      t.string   "imageURL"
      t.integer  "mother_id"
      t.integer  "father_id"
      t.boolean  "bred"
      t.integer  "user_id"
      t.integer  "stableOrder"
      t.boolean  "isEgg",           :default => false
      t.boolean  "isInMarketplace", :default => true
      t.integer  "activity_id"
      t.integer  "breeder_id"
      t.string   "breedTime",       :limit => 16
      t.boolean  "isMatchDragon",   :default => false

      t.timestamps
    end

    add_index "geniverse_dragons", ["activity_id"],                   :name => "index_dragons_on_activity_id"
    add_index "geniverse_dragons", ["breeder_id", "breedTime", "id"], :name => "breed_record_index"
    add_index "geniverse_dragons", ["father_id"],                     :name => "father_index"
    add_index "geniverse_dragons", ["id"],                            :name => "index_dragons_on_id"
    add_index "geniverse_dragons", ["mother_id"],                     :name => "mother_index"
    add_index "geniverse_dragons", ["user_id"],                       :name => "index_dragons_on_user_id"

    create_table "geniverse_help_messages", :force => true do |t|
      t.string   "page_name"
      t.text     "message"

      t.timestamps
    end

    create_table "geniverse_unlockables", :force => true do |t|
      t.string   "title"
      t.text     "content"
      t.string   "trigger"
      t.boolean  "open_automatically", :default => false

      t.timestamps
    end

    create_table "geniverse_users", :force => true do |t|
      t.string   "username"
      t.string   "password_hash"
      t.integer  "group_id"
      t.integer  "member_id"
      t.string   "first_name"
      t.string   "last_name"
      t.text     "note"
      t.string   "class_name"
      t.text     "metadata",  :limit => 4.megabytes
      t.string   "avatar"

      t.timestamps
    end

    # need to set a length here inorder to keep the total size of the index under 255
    # MySQL has a limit if 767 bytes per index and with utf8 3 bytes need to be reserved
    # for each char. 3*255 = 765.

    # this original migration has been modified because it should fail if run on a utf8 database.
    # there is another migration that re-adds this index so existing DBs can be migrated correctly.
    add_index "geniverse_users", ["username", "password_hash"],
      :name => "index_users_on_username_and_password_hash",
      length: {username: 125, password_hash: 125}

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
