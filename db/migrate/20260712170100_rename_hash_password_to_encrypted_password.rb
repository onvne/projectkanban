class RenameHashPasswordToEncryptedPassword < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :hash_password, :encrypted_password
  end
end
