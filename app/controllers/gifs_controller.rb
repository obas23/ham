class GifsController < ApplicationController

  def index
    @query = params[:q]
    if @query
      @gifs = Gif.search(@query)
    else
      @gifs = Gif.all
    end
  end

  def show
    @gif = Gif.find(params[:id])
  end

end

