include Auth0Helper
include TranslationsHelper

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
