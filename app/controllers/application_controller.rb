include Auth0Helper
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
