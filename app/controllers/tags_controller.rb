class TagsController < ApplicationController

  def index
    @query = params[:q]
    if @query.blank?
      @tags = Tag.all
    else
      @tags = Tag.search(@query)
    end
  end

  def show
    @tag = Tag.find(params[:id])
    @gifs = @tag.gifs
  end

  def create
    @gif = Gif.find(params[:gif_id])
    @gif.tag! params[:tag]
    redirect_to gif_path(@gif)
  end

  def destroy
    @gif = Gif.find(params[:gif_id])
    @gif.untag! params[:id]
    redirect_to gif_path(@gif)
  end

end

