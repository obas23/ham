class TagsController < ApplicationController
  def create
    @gif = Gif.find(params[:gif_id])
    @tag = Tag.find_or_create_by text: params[:tag][:text].strip

    if !@gif.tags.include?(@tag)
      @gif.tags << @tag
    end

    redirect_to gif_path(@gif)
  end

  def destroy
    @gif = Gif.find(params[:gif_id])
    @tag = @gif.tags.find(params[:id])
    @gif.tags.delete(@tag)
    redirect_to gif_path(@gif)
  end
end

