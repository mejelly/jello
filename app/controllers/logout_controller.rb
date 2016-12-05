class LogoutController < ApplicationController
  include LogoutHelper
  def logout
    reset_session
    redirect_to root_url
  end
end
