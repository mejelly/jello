class TranslationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_github_token, only: [:createGist, :updateGist]
  before_action :set_translation, only: [:show, :edit, :update, :destroy]
  after_action :insertTranslation, only: [:createGist]

  def get_user_info
    @user = current_user
    @currentuserid = @user[:extra][:raw_info][:user_id]
  end

  def create_connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def get_auth0_token(conn)
    req_body = "{ \"client_id\": \"#{ENV['AUTH0_CLIENT_ID']}\","
    req_body += " \"client_secret\": \"#{ENV['AUTH0_CLIENT_SECRET']}\", "
    req_body += '"audience": "https://mejelly.eu.auth0.com/api/v2/", "grant_type": "client_credentials" }'
    conn.post do |req|
      req.url '/oauth/token'
      req.headers['Content-Type'] = 'application/json'
      req.body = req_body
    end
  end

  def connect_github
    conn = create_connection('https://mejelly.eu.auth0.com')
    conn.headers = { 'Authorization': "Bearer #{JSON.parse(get_auth0_token(conn).body)['access_token'] }" }
    url = "/api/v2/users/#{URI.encode(session[:userinfo][:extra][:raw_info][:user_id]) }"
    conn.get(url)
  end

  def get_github_token
    @github_token = JSON.parse(connect_github.body)['identities'][0]['access_token']
  end

  def fetchGist(gist_id)
    get_github_token
    conn = create_connection('https://api.github.com')
    conn.headers = {
      'Authorization': "token #{@github_token}"
    }
    url = "/gists/#{gist_id}"
    JSON.parse(conn.get(url).body)['files'].each do |key, value|
      @translatedText = value['content']
      @gist_filename = value['filename']
    end
  end

  #CREATE GIST
  def createGist
    translationContent =  params[:translateHere].gsub(/[\r\n]+/, "<br>")
    @article_id = params[:article_id]
    response = post_to_gist(translationContent)
    @current_gist_id = JSON.parse(response.body)['id']
    insertTranslation
    redirect_after_create
  end

  def post_to_gist(translation_content)
    filename = @article_id + Time.now.to_i.to_s
    conn = create_connection('https://api.github.com')
    conn.headers = {
      'Authorization': "token #{@github_token}"
    }
    payload = '{"description": "Mejelly Test","public": true,"files": {"'+ filename +'.txt": {"content": "'
    payload += translation_content + '"}}}'
    conn.post('/gists', payload)
  end

  def redirect_after_create
    if insertTranslation.save
      redirect_to articles_url
    else
      puts '-----------Fail------------'
    end
  end

  def insertTranslation
    @article_section_hkey = params[:hightlight_key] # params[:articleSentence]
    get_user_info
    @translation = Translation.new(
      article_id:@article_id,
      user_id: @currentuserid,
      status: true,
      article_section: @article_section_hkey,
      translation_section:[],
      gist_id: @current_gist_id
    )
  end

  # def add_comment
  #   conn = create_connection('https://api.github.com')
  #   @current_gist_id = params[:current_gist_id]
  #   comment =  params[:comment].gsub(/[\r\n]+/, "<br />")
  #   #@article_id = params[:article_id]
  #   article_comment = '{ "body": "'+comment+'"}'
  #   response = conn.post do |req|
  #     req.url "/gists/#{@current_gist_id}/comments"
  #     req.headers['Content-Type'] = 'application/json'
  #     req.headers['Authorization'] = "token #{@github_token}"
  #     req.body = article_comment
  #   end
  #   puts article_comment
  #   puts '+=+++++++='
  #   puts response.body
  #   redirect_to :back
  #
  # end
  def update_gist_payload(translation_content)
    '{ "description": "updated gist", "public": true, "files": { "' \
    + params[:gist_filename] +'": { "content": "' + translation_content +'" } } }'
  end

  #UPDATE edited Gist
  def updateGist
    @article_id = params[:article_id]
    @current_gist_id = params[:current_gist_id]
    translation_content =  params[:translateHere].gsub(/[\r\n]+/, "<br />")
    conn = create_connection('https://api.github.com')
    conn.headers = {
      Authorization: "token #{@github_token}"
    }
    conn.patch("/gists/#{@current_gist_id}", update_gist_payload(translation_content))
    insertTranslation
    redirect_after_create
  end

  def index
    @translations = Translation.all
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
  end

  # GET /translations/new
  def new
    @translation = Translation.new
  end

  # GET /translations/1/edit
  def edit
  end

  # def createSequenceJson(inputText)
  #   article_arr = inputText.split('.')
  #   i=0
  #   temp_json='{'
  #   article_arr.each do |item|
  #     if(i>0)
  #       temp_json += ','
  #     end
  #     i=i+1
  #     temp_json += "\"" + @article_id + @user_id + i.to_s + "\":\"" + item + "\""
  #   end
  #   temp_json +='}'
  #
  # end

  def translate
    @article_id = params[:article_id]
    @originalArticle = Article.find_by(id: @article_id)
    get_user_info
    check_translation = Translation.order('id DESC').limit(1).find_by(user_id: @currentuserid , article_id: @article_id)

    @translatedText = ''
    if(!check_translation.nil?)
      @current_gist_id = check_translation.gist_id
      @article_section = check_translation.article_section
      fetchGist(@current_gist_id)
    end

    #@article_json = createSequenceJson(@originalArticle.content)
  end

  # def saveGist
  #   if (!params[:translateHere].nil? || cookies[:translatedText].to_s!=params[:translateHere].to_s)
  #    cookies[:translatedText] = params[:translateHere]
  #   end
  #   @translatedText=cookies[:translatedText]
  #   redirect_to :back
  # end

  # POST /translations
  # POST /translations.json
  def create
    @translation = Translation.new(translation_params)

    respond_to do |format|
      if @translation.save
        format.html { redirect_to @translation, notice: 'Translation was successfully created.' }
        format.json { render :show, status: :created, location: @translation }
      else
        format.html { render :new }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /translations/1
  # PATCH/PUT /translations/1.json
  def update
    respond_to do |format|
      if @translation.update(translation_params)
        format.html { redirect_to @translation, notice: 'Translation was successfully updated.' }
        format.json { render :show, status: :ok, location: @translation }
      else
        format.html { render :edit }
        format.json { render json: @translation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.json
  def destroy
    @translation.destroy
    respond_to do |format|
      format.html { redirect_to translations_url, notice: 'Translation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_translation
      @translation = Translation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def translation_params
      params.require(:translation).permit(:article_id, :user_id, :status, :article_section, :translation_section)
    end
end
