class AddUserNameToTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :translations, :user_name, :string
  end
end
