require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TranslationsHelper. For example:
#
# describe TranslationsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe TranslationsHelper, type: :helper do
  it "purge cache should return ok" do
    VCR.use_cassette 'helpers/purge_cache' do
      response = purge_cache('/gists/d3384bd4408a856f8bff235d4ddf0310')
      expect(response.body).to eq("OK\n")
    end
  end
end
