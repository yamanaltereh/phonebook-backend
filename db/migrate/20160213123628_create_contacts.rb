class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.text :bio
      t.date :birthday

      t.timestamps null: false
    end
  end
end
