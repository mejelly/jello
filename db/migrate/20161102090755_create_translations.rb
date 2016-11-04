class CreateTranslations < ActiveRecord::Migration[5.0]
  def change
    create_table :translations do |t|
      t.references :article, foreign_key: true
      t.string :user_id
      t.boolean :status
      t.string :article_section
      t.string :translation_section, array: true

      t.timestamps
    end
  end
end
