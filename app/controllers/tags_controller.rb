class TagsController < ApplicationController

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

