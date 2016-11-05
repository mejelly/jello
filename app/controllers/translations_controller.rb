class TranslationsController < ApplicationController
  before_action :set_translation, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :gist, only: [:createGist, :updateGist]
  after_action :insertTranslation, only: [:createGist]
  # GET /translations
  # GET /translations.json

  def gistConnection(url)
    conn = Faraday.new(url: url ) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def gist
    #Initial part
    client_id = ENV['AUTH0_CLIENT_ID']
    client_id_secret = ENV['AUTH0_CLIENT_SECRET']
    user_id = URI.encode(session[:userinfo][:extra][:raw_info][:user_id])
    conn = gistConnection('https://mejelly.eu.auth0.com')
    req_body = "{ \"client_id\": \"#{client_id}\", \"client_secret\": \"#{client_id_secret}\", \"audience\": \"https://mejelly.eu.auth0.com/api/v2/\", \"grant_type\": \"client_credentials\" }"
    auth0_token = conn.post do |req|
      req.url '/oauth/token'
      req.headers['Content-Type'] = 'application/json'
      req.body = req_body
    end

    auth0_token = JSON.parse(auth0_token.body)['access_token']


    github_resp = conn.get do |req|
      req.url "/api/v2/users/#{user_id}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{auth0_token}"
      req.body = req_body
    end

    @github_token = JSON.parse(github_resp.body)['identities'][0]['access_token']

  end

  #FETCH GIST
  def fetchGist(gist_id)
    gist
    conn = gistConnection('https://api.github.com')
    response = conn.get do |req|
      req.url "/gists/#{gist_id}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "token #{@github_token}"
     #req.body = patch_body
    end
    temp = JSON.parse(response.body)['files']
    temp.each do |key, value|
      @translatedText = value['content']
      @gist_filename = value['filename']
    end
  end

  #CREATE GIST
  def createGist

    translationContent =  params[:translateHere].gsub(/[\r\n]+/, "<br>")
    @article_id = params[:article_id]
    filename = @article_id + Time.now.to_i.to_s
    conn = gistConnection('https://api.github.com')

    response = conn.post do |req|
      req.url '/gists'
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "token #{@github_token}"
      req.body = '{"description": "Mejelly Test","public": true,"files": {"'+ filename +'.txt": {"content": "'+ translationContent +'"}}}'
    end

    response_json = JSON.parse(response.body)
    @current_gist_id = response_json['id']

    #@user_id = current_user[:uid]


    translation_section=[]
    #i = 0
    # @article_json = createSequenceJson(translationContent)
    # JSON.parse(@article_json).each do |line|
    #   translation_section[i]=line[0]
    #   i +=1
    # end
    insertTranslation
    if insertTranslation.save
      redirect_to articles_url
    else
      puts '-----------Fail------------'
    end
  end

  def insertTranslation
    @article_section_hkey = params[:hightlight_key] # params[:articleSentence]
    @user_id = params[:user_id]
    @translation = Translation.new(article_id:@article_id, user_id: @user_id, status: true, article_section: @article_section_hkey, translation_section:[], gist_id: @current_gist_id)

  end

  #UPDATE edited Gist
  def updateGist
    conn = gistConnection('https://api.github.com')
    @current_gist_id = params[:current_gist_id]
    translationContent =  params[:translateHere].gsub(/[\r\n]+/, "<br />")
    @article_id = params[:article_id]
    gist_filename = params[:gist_filename]
    patch_body = '{ "description": "updated gist", "public": true, "files": { "'+ gist_filename +'": { "content": "'+ translationContent +'" } } }'
    response = conn.patch do |req|
      req.url "/gists/#{@current_gist_id}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "token #{@github_token}"
      req.body = patch_body
    end

    insertTranslation
    if insertTranslation.save
      redirect_to articles_url
    else
      puts '-----------Update Fail------------'
    end
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
   # @translatedText=cookies[:translatedText]
    @article_id = params[:article_id]
    @user_id = params[:user_id]
    @originalArticle=Article.find_by(user_id: @user_id, id: @article_id)
    check_translation = Translation.order('id DESC').limit(1).find_by(user_id: @user_id, article_id: @article_id)
    @translatedText = ''
    if(!check_translation.nil?)
      @current_gist_id = check_translation.gist_id
      @article_section = check_translation.article_section
      translation_section = check_translation.translation_section
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
