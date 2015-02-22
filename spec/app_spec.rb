require 'spec_helper'

RSpec.describe App, 'GET /' do
  it "searches gifs when there is a query" do
    gifs = double
    expect(Gif).to receive(:search).with('search term') { gifs }
    get '/', q: 'search term'
  end

  it "finds all gifs when there is no query" do
    gifs = double
    expect(Gif).to receive(:all) { gifs }
    get '/'
  end
end

RSpec.describe App, 'GET /:id' do
  it "finds the gif" do
    gif = double
    expect(Gif).to receive(:retrieve).with("gif123").and_return(gif)
    get '/gif123'
  end
end

RSpec.describe App, 'GET /tags' do
  it "searches tags when there is a query" do
    tags = double
    expect(Tag).to receive(:search).with('search term') { tags }
    get '/tags', q: 'search term'
  end

  it "finds all tags when there is no query" do
    tags = double
    expect(Tag).to receive(:all) { tags }
    get '/tags'
  end
end

RSpec.describe App, 'GET /tags/:id' do
  it "finds the tag" do
    tag = double
    expect(Tag).to receive(:retrieve).with("tag123").and_return(tag)
    get '/tags/tag123'
  end
end

RSpec.describe App, 'POST /:id/tags' do
  let(:gif) { double(id: "gif123") }

  before do
    allow(Gif).to receive(:retrieve) { gif }
    allow(gif).to receive(:tag!)
  end

  it "tags the gif" do
    expect(Gif).to receive(:retrieve).with("gif123").and_return(gif)
    expect(gif).to receive(:tag!).with('tag-text')
    post '/gif123/tags', tag: 'tag-text'
  end

  it "redirects to the gif" do
    post '/gif123/tags', tag: 'tag-text'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to eql 'http://example.org/gif123'
  end
end

RSpec.describe App, 'DELETE /:id/tags/:tag' do
  let(:gif) { double(id: "gif123") }

  before do
    allow(Gif).to receive(:retrieve) { gif }
    allow(gif).to receive(:untag!)
  end

  it "untags the gif" do
    expect(Gif).to receive(:retrieve).with("gif123").and_return(gif)
    expect(gif).to receive(:untag!).with('tag-text')
    delete '/gif123/tags/tag-text', tag: 'tag-text'
  end

  it "redirects to the gif" do
    delete '/gif123/tags/tag-text', tag: 'tag-text'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_request.url).to eql 'http://example.org/gif123'
  end
end


