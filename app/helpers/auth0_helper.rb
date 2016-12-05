module Auth0Helper
  private

  # Is the user signed in?
  # @return [Boolean]
  def user_signed_in?
    session[:userinfo].present?
  end

  # Set the @current_user or redirect to public page
  def authenticate_user!
    # Redirect to page that has the login here
    if user_signed_in?
      @current_user = session[:userinfo]
    else
      redirect_to login_path
    end
  end

  # What's the current_user?
  # @return [Hash]
  def current_user
    @current_user = session[:userinfo]
    @current_user
  end

  def get_user_info
    @user = current_user
    @currentuser=[]
    if(!@user.nil?)
      @currentuserid = @user[:extra][:raw_info][:user_id]
      @currentuser[0] = @currentuserid
      @currentuser[1] = @user[:info][:name]
    end
    @currentuser
  end

  def create_connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def get_auth0_token
    conn = create_connection('https://mejelly.eu.auth0.com')
    req_body = "{ \"client_id\": \"#{ENV['AUTH0_CLIENT_ID']}\","
    req_body += " \"client_secret\": \"#{ENV['AUTH0_CLIENT_SECRET']}\", "
    req_body += '"audience": "https://mejelly.eu.auth0.com/api/v2/", "grant_type": "client_credentials" }'
    conn.post do |req|
      req.url '/oauth/token'
      req.headers['Content-Type'] = 'application/json'
      req.body = req_body
    end
  end

  # @return the path to the login page
  def login_path
    root_path
  end
end