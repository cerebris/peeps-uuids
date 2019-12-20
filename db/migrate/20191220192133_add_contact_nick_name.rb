class AddContactNickName < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :nick_name, :string
  end
end
