class AddGistIdToTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :translations, :gist_id, :string
  end
end
