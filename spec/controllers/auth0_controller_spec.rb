require 'rails_helper'

RSpec.describe Auth0Controller, type: :controller do

  describe "GET #callback" do
    before(:each) do
      valid_auth0_login_setup
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:auth0]
      get :callback
    end

    it "should set uid" do
      expect(session['userinfo']['uid']).to eq('github|123545')
    end

    it "should redirect to root" do
      expect(response).to redirect_to root_path
    end
  end

  describe "GET #failure" do
    it "returns http success" do
      get :failure
      expect(response).to redirect_to root_path
    end
  end
end
