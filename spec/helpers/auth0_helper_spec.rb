require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Auth0Helper. For example:
#
# describe Auth0Helper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Auth0Helper, type: :helper do
  it "get_auth0_token should returns an auth0 token" do
    VCR.use_cassette 'helpers/auth0_token' do
      actual = get_auth0_token
      expect(actual).not_to be_nil
    end
  end
end
