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
      puts @current_user
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
    if(!@user.nil?)
      @currentuserid = @user[:extra][:raw_info][:user_id]
    end
  end

  def connect_github
    conn = create_connection('https://mejelly.eu.auth0.com')
    conn.headers = { 'Authorization': "Bearer #{JSON.parse(get_auth0_token(conn).body)['access_token'] }" }
    url = "/api/v2/users/#{URI.encode(session[:userinfo][:extra][:raw_info][:user_id]) }"
    conn.get(url)
  end

  # @return the path to the login page
  def login_path
    root_path
  end
end