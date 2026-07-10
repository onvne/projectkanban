class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :hash_password, null: false
      t.datetime :create_time
      t.datetime :last_activity_time
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :last_activity_time
  end
end
