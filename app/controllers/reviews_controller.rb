class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_post,only: [:edit, :update]

  def create
    @camp_site = CampSite.find(params[:review][:camp_site_id])
    @review = Review.new(review_params)
    @review.user_id = current_user.id
    @region = Region.find_by(id: params[:region_id])
    if @review.save
      flash[:notice] = "レビューを投稿しました"
      redirect_to region_camp_site_path(region_id: @region.id, id: @camp_site.id)
    else
      @camp_site = CampSite.find(params[:review][:camp_site_id])
      @reviews = @camp_site.reviews.page(params[:page]).per(5)
      @posts = Post.where(camp_site_id: @camp_site.id)
      render template: 'camp_sites/show'
    end
  end

  def destroy
    @camp_site = CampSite.find(params[:camp_site_id])
    @review = Review.find(params[:id])
    @review.destroy
    flash[:notice] = "レビューを削除しました"
    redirect_back(fallback_location: root_path)
  end

  def edit
    @region = Region.find_by(id: params[:region_id])
    @camp_site = CampSite.find(params[:camp_site_id])
    @review = Review.find(params[:id])
  end

  def update
    @region = Region.find_by(id: params[:region_id])
    @camp_site = CampSite.find(params[:review][:camp_site_id])
    @review = Review.find(params[:id])
    if @review.update(review_params)
      flash[:notice] = "レビューを編集しました"
      redirect_to region_camp_site_path(@region.id, @camp_site.id)
    else
      @camp_site = CampSite.find(params[:camp_site_id])
      render :edit
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :camp_site_id, :body, :score)
  end

  def ensure_correct_post
    @review = Review.find(params[:id])
    @user = @review.user
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end

end
