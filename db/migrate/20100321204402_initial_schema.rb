class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    
    create_table :roles do |t|
      t.string :name, :limit => 40, :null => false
      t.boolean :can_manage_financial_data, :null => false, :default => false
    end
    
    add_index :roles, :name, :unique => true
    
    create_table :clients do |t|
      t.string :name, :limit => 40, :null => false
      t.text :description
      t.string :email, :limit => 100
      t.boolean :active, :null => false, :default => true
    end

    create_table :users, :force => true do |t|
      t.string :login, :limit => 40, :null => false
      t.string :name, :limit => 100, :null => false
      t.string :email, :limit => 100, :null => false
      t.string :password_hash, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :remember_token, :limit => 40
      t.datetime :remember_token_expires_at
      t.boolean :active, :null => false, :default => true
      t.boolean :admin, :null => false, :default => false
      t.references :role
      t.references :client
      t.string :login_key
    end
    
    add_index :users, :login, :unique => true
    
    create_table :currencies do |t|
      t.string :name, :null => false
      t.string :plural, :null => false
      t.string :symbol, :null => false
      t.boolean :prefix, :null => false
    end
    
    add_index :currencies, :name, :unique => true
    add_index :currencies, :plural, :unique => true
    add_index :currencies, :symbol, :unique => true
    
    create_table :invoices do |t|
      t.string :name, :null => false
      t.text :notes
      t.references :user, :null => false
      t.references :client, :null => false
      t.date :issued_at
      t.datetime :created_at
    end
    
    create_table :projects do |t|
      t.string :name, :null => false
      t.text :description
      t.references :client, :null => false
      t.boolean :active, :null => false, :default => true
      t.datetime :created_at
    end
    
    create_table :activities do |t|
      t.text :comments, :null => false
      t.date :date, :null => false
      t.integer :minutes, :size => 5, :null => false, :default => 0
      t.references :project, :null => false
      t.references :user, :null => false
      t.references :invoice
      t.date :invoiced_at
      t.decimal :value, :precision => 8, :scale => 2
      t.references :currency
      t.timestamps
    end
    
    add_index :activities, [:date, :project_id, :user_id], :name => :main, :unique => true
    
    create_table :hourly_rates do |t|
      t.references :project, :null => false
      t.references :role, :null => false
      t.date :date, :null => false
      t.decimal :value, :precision => 8, :scale => 2, :null => false
      t.references :currency, :null => false
    end
    
    add_index :hourly_rates, [:project_id, :role_id, :date], :name => :main, :unique => true
    
    create_table :hourly_rate_logs do |t|
      t.datetime :logged_at
      t.string :operation_type, :size => 50, :null => false
      t.integer :operation_author_id, :null => false
      t.integer :hr_project_id
      t.integer :hr_role_id
      t.date :hr_takes_effect_at
      t.decimal :hr_value, :precision => 8, :scale => 2
      t.integer :hr_currency_id
    end
    
    create_table :free_days do |t|
      t.date :date, :null => false
      t.references :user, :null => false
    end
    
    add_index :free_days, [:date, :user_id], :name => :main, :unique => true
    
    create_table :settings do |t|
      t.boolean :enable_notifications, :null => false
      t.string :free_days_access_key, :size => 50, :null => false
    end
  end
  
  def self.down
    drop_table :sessions
    drop_table :roles
    drop_table :clients
    drop_table :users
    drop_table :currencies
    drop_table :invoices
    drop_table :projects
    drop_table :activities
    drop_table :hourly_rates
    drop_table :hourly_rate_logs
    drop_table :free_days
    drop_table :settings
  end
end
