class TranslationsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :get_github_token, only: [:create_gist, :update_gist, :add_comment]
  before_action :set_translation, only: [:show, :edit, :update, :destroy]
  after_action :insert_translation, only: [:create_gist]
  before_action :get_user_info, only: [:insert_translation, :translate, :show, :profile]

  def connect_github
    conn = create_connection('https://mejelly.eu.auth0.com')
    conn.headers = { 'Authorization': "Bearer #{JSON.parse(get_auth0_token.body)['access_token'] }" }
    url = "/api/v2/users/#{URI.encode(session[:userinfo][:extra][:raw_info][:user_id])}"
    conn.get(url)
  end

  def get_github_token
    @github_token = JSON.parse(connect_github.body)['identities'][0]['access_token']
  end

  def fetch_gist
    get_github_token
    conn = create_connection('http://gist.mejelly.com:8000')
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
    insert_translation.save
    render json: { current_gist_id: @current_gist_id}
    # redirect_after_create
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

  # def redirect_after_create
  #   if insert_translation.save
  #     redirect_to :back
  #   end
  # end

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
    gist_uri = "/gists/#{@current_gist_id}/comments"
    purge_cache(gist_uri)
    comment =  params[:comment].gsub(/[\r\n]+/, "<br />")
    conn = create_connection('https://api.github.com')
    conn.headers = {
        'Authorization': "token #{@github_token}"
    }
    payload = '{ "body": "'+comment+'"}'
    conn.post(gist_uri, payload)
    list_comments
    #redirect_to :back
  end

  def list_comments
    response = create_connection('http://gist.mejelly.com:8000').get do |req|
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
    gist_uri = "/gists/#{@current_gist_id}"
    purge_cache(gist_uri)
    translation_content =  params[:translateHere].gsub(/[\r\n]+/, "<br />")
    conn = create_connection('https://api.github.com')
    conn.headers = {
      Authorization: "token #{@github_token}"
    }
    conn.patch(gist_uri, update_gist_payload(translation_content))
    insert_translation
    # redirect_after_create
    if insert_translation.save
      redirect_to :back
    end
  end

  def index
    @translations = Translation.all
  end

  # GET /translations/1
  # GET /translations/1.json
  def show
    @current_gist_id = @translation.gist_id
    @article = Article.find(@translation.article_id)
    response = create_connection('http://gist.mejelly.com:8000').get do |req|
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

  def profile
    userinfo = get_user_info
    first_phase=Translation.select("max(created_at) as date, gist_id").group("gist_id")
    query=''
    first_phase.each do |t|
      tempdate=t.date.to_s.chomp(' UTC')
      query +="(translations.created_at::text like '#{tempdate}%' AND translations.gist_id = '#{t.gist_id}') OR "
    end
    @articles = Article.select("translations.id as tid, translations.user_id as translator_id, translations.user_name,translations.created_at as tdate,translations.article_section as article_section, articles.*")
                    .joins("LEFT JOIN translations on translations.article_id = articles.id").where("translations.user_id =?",userinfo[0])
                    .where(query.chomp('OR '))
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
  # def update
  #   respond_to do |format|
  #     if @translation.update(translation_params)
  #       format.html { redirect_to @translation, notice: 'Translation was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @translation }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @translation.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
