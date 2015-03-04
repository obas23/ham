module Ham
  class API < Sinatra::Base
    configure do
      enable :logging
      use Rack::Logger, STDOUT

      set :dump_errors, false
      set :raise_errors, true
      set :show_exceptions, false
    end

    before do
      content_type :json
    end

    error do
      halt 500, { error: { message: "Stop doing it wrong." } }.to_json
    end

    error 404 do
      halt 404, { error: { message: "Not Found" } }.to_json
    end

    error ObjectNotFound do
      halt 404, { error: { message: "Not Found" } }.to_json
    end

    get "/gifs" do
      gifs = Gif.search(params[:q])
      gifs.to_json
    end

    post "/gifs" do
      status 201
      gif = Gif.create(params[:gif])
      gif.to_json
    end

    get "/gifs/:gif" do
      gif = Gif.retrieve(params[:gif])
      gif.to_json
    end

    get "/gifs/:gif/tags" do
      gif = Gif.retrieve(params[:gif])
      gif.tags.to_json
    end

    post "/gifs/:gif/tags" do
      status 201
      tag = Gif.tag(params[:gif], params[:tag])
      tag.to_json
    end

    delete "/gifs/:gif/tags/:tag" do
      status 202
      tag = Gif.untag(params[:gif], params[:tag])
      tag.to_json
    end

    get "/tags" do
      tags = Tag.search(params[:q])
      tags.to_json
    end

    get "/tags/complete" do
      tags = Tag.complete(params[:q])
      tags.to_json
    end

  end
end

