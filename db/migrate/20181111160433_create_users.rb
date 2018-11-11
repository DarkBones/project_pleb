class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :password
      t.string :salt
      t.references :subscription_tier
      t.references :country
      t.timestamps
    end
  end
end
