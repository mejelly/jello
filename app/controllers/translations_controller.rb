class TranslationsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :get_github_token, only: [:create_gist, :update_gist, :add_comment]
  before_action :set_translation, only: [:show, :edit, :update, :destroy]
  after_action :insert_translation, only: [:create_gist]
  before_action :get_user_info, only: [:insert_translation, :translate, :show]

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

  def get_github_token
    @github_token = JSON.parse(connect_github.body)['identities'][0]['access_token']
  end

  def fetch_gist
    get_github_token
    conn = create_connection('https://api.github.com')
    conn.headers = {
      'Authorization': "token #{@github_token}"
    }

    url = "/gists/#{@current_gist_id}"
    JSON.parse(conn.get(url).body)['files'].each do |key, value|
      @translatedText = value['content']
      @gist_filename = value['filename']
    end
  end

  #CREATE GIST
  def create_gist
    translationContent =  params[:translateHere].gsub(/[\r\n]+/, "<br>")
    @article_id = params[:article_id]
    response = post_to_gist(translationContent)
    @current_gist_id = JSON.parse(response.body)['id']
    insert_translation
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
    if insert_translation.save
      redirect_to articles_url
    else
      puts '-----------Fail------------'
    end
  end

  def insert_translation
    get_user_info
    @article_section_hkey = params[:hightlight_key] # params[:articleSentence]
    @translation = Translation.new(
      article_id:@article_id,
      user_id: @currentuser[0],
      status: true,
      article_section: @article_section_hkey,
      translation_section:[],
      gist_id: @current_gist_id,
      user_name: @currentuser[1]
    )
  end

  def add_comment
    @current_gist_id = params[:current_gist_id]
    comment =  params[:comment].gsub(/[\r\n]+/, "<br />")
    conn = create_connection('https://api.github.com')
    conn.headers = {
        'Authorization': "token #{@github_token}"
    }
    payload = '{ "body": "'+comment+'"}'
    conn.post("/gists/#{@current_gist_id}/comments", payload)
    redirect_to :back
  end

  def list_comments
    response = create_connection('https://api.github.com').get do |req|
      req.url "/gists/#{@current_gist_id}/comments"
      req.headers['Content-Type'] = 'application/json'
    end
    @comments = response.body
  end

  def update_gist_payload(translation_content)
    '{ "description": "updated gist", "public": true, "files": { "' \
    + params[:gist_filename] +'": { "content": "' + translation_content +'" } } }'
  end

  #UPDATE edited Gist
  def update_gist
    @article_id = params[:article_id]
    @current_gist_id = params[:current_gist_id]
    translation_content =  params[:translateHere].gsub(/[\r\n]+/, "<br />")
    conn = create_connection('https://api.github.com')
    conn.headers = {
      Authorization: "token #{@github_token}"
    }
    conn.patch("/gists/#{@current_gist_id}", update_gist_payload(translation_content))
    insert_translation
    redirect_after_create
  end

  def index
    @translations = Translation.all
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
    @current_gist_id = @translation.gist_id
    @article = Article.find(@translation.article_id)
    response = create_connection('https://api.github.com').get do |req|
      req.url '/gists/'+@current_gist_id
      req.headers['Content-Type'] = 'application/json'
    end
    JSON.parse(response.body)['files'].each do |key, value|
      @translatedText = value['content']
      @gist_filename = value['filename']
    end
    if(!@translation.nil?)
      list_comments
    end
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
    check_translation = Translation.order('id DESC').limit(1).find_by(user_id: @currentuser[0] , article_id: @article_id)

    @translatedText = ''
    if(!check_translation.nil?)
      @current_gist_id = check_translation.gist_id
      @article_section = check_translation.article_section
      fetch_gist
      list_comments
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
