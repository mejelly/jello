require 'rails_helper'

RSpec.describe LogoutController, type: :controller do

  describe "GET #logout" do
    it "returns http success" do
      get :logout
      expect(response).to have_http_status(:success)
    end
  end

end
