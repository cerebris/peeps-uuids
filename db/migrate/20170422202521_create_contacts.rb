class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :twitter

      t.timestamps
    end
  end
end
