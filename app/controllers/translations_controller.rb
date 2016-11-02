class TranslationsController < ApplicationController
  before_action :set_translation, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  # GET /translations
  # GET /translations.json
  
  def gist
    # Initial part
    # client_id = ENV['AUTH0_CLIENT_ID']
    # client_id_secret = ENV['AUTH0_CLIENT_SECRET']
    # user_id = URI.encode(session[:userinfo][:extra][:raw_info][:user_id])
    #
    # conn = Faraday.new(url: 'https://mejelly.eu.auth0.com') do |faraday|
    #   faraday.request  :url_encoded             # form-encode POST params
    #   faraday.response :logger                  # log requests to STDOUT
    #   faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    # end
    #
    # req_body = "{ \"client_id\": \"#{client_id}\", \"client_secret\": \"#{client_id_secret}\", \"audience\": \"https://mejelly.eu.auth0.com/api/v2/\", \"grant_type\": \"client_credentials\" }"
    # auth0_token = conn.post do |req|
    #   req.url '/oauth/token'
    #   req.headers['Content-Type'] = 'application/json'
    #   req.body = req_body
    # end
    #
    # auth0_token = JSON.parse(auth0_token.body)['access_token']
    #
    # conn = Faraday.new(url: 'https://mejelly.eu.auth0.com') do |faraday|
    #   faraday.request  :url_encoded             # form-encode POST params
    #   faraday.response :logger                  # log requests to STDOUT
    #   faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    # end
    #
    # github_resp = conn.get do |req|
    #   req.url "/api/v2/users/#{user_id}"
    #   req.headers['Content-Type'] = 'application/json'
    #   req.headers['Authorization'] = "Bearer #{auth0_token}"
    #   req.body = req_body
    # end
    #
    # github_token = JSON.parse(github_resp.body)['identities'][0]['access_token']

    # CREATE GIST
    # conn = Faraday.new(url: 'https://api.github.com') do |faraday|
    #   faraday.request  :url_encoded             # form-encode POST params
    #   faraday.response :logger                  # log requests to STDOUT
    #   faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    # end
    #
    # response = conn.post do |req|
    #   req.url '/gists'
    #   req.headers['Content-Type'] = 'application/json'
    #   req.headers['Authorization'] = "token #{github_token}"
    #   req.body = '{"description": "Mejelly Test","public": true,"files": {"5mejellytest.txt": {"content": "jelatio"}}}'
    # end

    # UPDATE edited Gist
    # conn = Faraday.new(url: 'https://api.github.com') do |faraday|
    #   faraday.request  :url_encoded             # form-encode POST params
    #   faraday.response :logger                  # log requests to STDOUT
    #   faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    # end
    #
    # gist_id = '7bf8be959eaf68ee5f4ff135bf1c874a'
    # patch_body = '{ "description": "updated gist", "public": true, "files": { "5mejellytest.txt": { "filename": "9005mejellytest.txt", "content": "String file contents are now updated" } } }'
    # response = conn.patch do |req|
    #   req.url "/gists/#{gist_id}"
    #   req.headers['Content-Type'] = 'application/json'
    #   req.headers['Authorization'] = "token #{github_token}"
    #   req.body = patch_body
    # end
    #
    # puts response.body

    respond_to do |format|
       format.html { render :hello }
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
    git @translation = Translation.new
  end

  # GET /translations/1/edit
  def edit
  end

  def translate
    puts params[:article_id]
    puts params[:user_id]
    @originalArticle=Article.find_by(user_id: params[:user_id], id: params[:article_id])
    puts @originalArticle
    #format.html { render :translate }
  end
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
