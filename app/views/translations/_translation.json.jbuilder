json.extract! translation, :id, :article_id, :user_id, :status, :article_section, :translation_section, :created_at, :updated_at
json.url translation_url(translation, format: :json)