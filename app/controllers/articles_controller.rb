class ArticlesController < ApplicationController
  before_action :set_article, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :get_user_info, only: [:index, :show, :new]

  # GET /articles
  # GET /articles.json

  def index
    first_phase=Translation.select("max(created_at) as date, gist_id").group("gist_id")
    query=''
    first_phase.each do |t|
      tempdate=t.date.to_s.chomp(' UTC')
      query +="(translations.created_at::text like '#{tempdate}%' AND translations.gist_id = '#{t.gist_id}') OR "
    end
    @articles = Article.select("translations.id as tid, translations.user_id as translator_id, translations.user_name,translations.created_at as tdate, articles.*")
                      .joins("INNER JOIN translations on translations.article_id = articles.id")
                      .where(query.chomp('OR ')).order('translations.updated_at desc')
    @newarticles = Article.includes(:translations).where( :translations => { :article_id => nil } ).order('articles.created_at desc')
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  # def edit
  # end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  # def update
  #   respond_to do |format|
  #     if @article.update(article_params)
  #       format.html { redirect_to @article, notice: 'Article was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @article }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @article.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:user_id, :title, :url, :content)
    end
end
