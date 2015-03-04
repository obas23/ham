module Ham
  class API < Sinatra::Base
    configure do
      enable :logging
      use Rack::Logger, STDOUT
    end

    get "/gifs" do
      content_type :json
      gifs = Gif.search(params[:q])
      gifs.to_json
    end

    post "/gifs" do
      content_type :json
      status 201
      gif = Gif.create(params[:gif])
      gif.to_json
    end

    get "/gifs/:gif" do
      content_type :json
      gif = Gif.retrieve(params[:gif])
      gif.to_json
    end

    get "/gifs/:gif/tags" do
      content_type :json
      gif = Gif.retrieve(params[:gif])
      gif.tags.to_json
    end

    post "/gifs/:gif/tags" do
      content_type :json
      status 201
      gif = Gif.retrieve(params[:gif])
      tag = gif.tag! params[:tag]
      tag.to_json
    end

    delete "/gifs/:gif/tags/:tag" do
      content_type :json
      status 202
      gif = Gif.retrieve(params[:gif])
      tag = gif.untag! params[:tag]
      tag.to_json
    end

    get "/tags" do
      content_type :json
      tags = Tag.search(params[:q])
      tags.to_json
    end

    get "/tags/complete" do
      content_type :json
      tags = Tag.complete(params[:q])
      tags.to_json
    end

  end
end

