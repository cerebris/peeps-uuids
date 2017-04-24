class CreatePhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :phone_numbers, id: :uuid do |t|
      t.uuid :contact_id
      t.string :name
      t.string :phone_number

      t.timestamps
    end
  end
end
