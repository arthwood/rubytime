class AddLoginKeyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :login_key, :string
  end

  def self.down
    remove_column :users, :login_key
  end
end
