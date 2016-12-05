require 'rails_helper'

RSpec.describe "Translations", type: :request do
  describe "GET /translations" do
    it "works! (now write some real specs)" do
      get translations_path
      expect(response).to have_http_status(302)
      expected_body = '<html><body>You are being <a href="http://www.example.com/">redirected</a>.</body></html>'
      expect(response.body).to eq(expected_body)
    end
  end
end
