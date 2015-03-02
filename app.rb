$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

Bundler.require

require 'json'
require 'lib/model'
require 'lib/gif'
require 'lib/tag'

Redis.current = Redis.new url: ENV.fetch('REDIS_URL')
$redis ||= Redis.current

class App < Sinatra::Base
  configure do
    enable :logging
    use Rack::Logger, STDOUT
  end

  get "/" do
    @query = params[:q]
    @gifs = Gif.search(@query)
    erb :gifs
  end

  get "/tags" do
    @query = params[:q]
    @tags = Tag.search(@query)
    erb :tags
  end

  get "/tags/complete" do
    @query = params[:q]
    @tags = Tag.complete(@query)
    content_type :json
    @tags.map(&:to_s).to_json
  end

  get "/tags/:tag" do
    @tag = Tag.retrieve(params[:tag])
    @gifs = @tag.gifs
    erb :tag
  end

  delete "/:id/tags/:tag" do
    @gif = Gif.retrieve(params[:id])
    @gif.untag! params[:tag]
    redirect "/#{@gif.id}"
  end

  post "/:id/tags" do
    @gif = Gif.retrieve(params[:id])
    @gif.tag! params[:tag]
    redirect "/#{@gif.id}"
  end

  get "/:id" do
    @gif = Gif.retrieve(params[:id])
    erb :gif
  end
end

