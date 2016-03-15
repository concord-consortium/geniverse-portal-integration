class ShortenGeniverseUsersIndex < ActiveRecord::Migration
  def up
    # need to set a length here inorder to keep the total size of the index under 255
    # MySQL has a limit if 767 bytes per index and with utf8 3 bytes need to be reserved
    # for each char. 3*255 = 765.

    # this index is also added by a modified older migation since that old migration would
    # have failed when run on a utf8 database

    if index_exists? :geniverse_users, [:username, :password_hash],
         name: "index_users_on_username_and_password_hash"
      remove_index :geniverse_users, name: "index_users_on_username_and_password_hash"
    end

    add_index :geniverse_users, [:username, :password_hash],
      name: "index_users_on_username_and_password_hash",
      length: {username: 125, password_hash: 125}
  end

  def down
    if index_exists? :geniverse_users, [:username, :password_hash],
         name: "index_users_on_username_and_password_hash"
      remove_index :geniverse_users, name: "index_users_on_username_and_password_hash"
    end
    add_index :geniverse_users, [:username, :password_hash],
      name: "index_users_on_username_and_password_hash"
  end
end
