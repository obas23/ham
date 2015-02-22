require 'rails_helper'


RSpec.describe TagsController, '#index', type: :controller do
  let(:all_tags) { double }
  let(:matching_tags) { double }

  before do
    allow(Tag).to receive(:all) { all_tags }
    allow(Tag).to receive(:search).with('search term') { matching_tags }
  end

  it "returns http success" do
    get :index
    expect(response).to have_http_status(:success)
  end

  context "when there is a query present" do
    it "assigns all tags" do
      get :index
      expect(assigns(:tags)).to eql all_tags
    end
  end

  context "when there is not a query present" do
    it "assigns all tags" do
      get :index, q: 'search term'
      expect(assigns(:tags)).to eql matching_tags
    end
  end
end

RSpec.describe TagsController, '#show', type: :controller do
  let(:gifs) { double }
  let(:tag)  { double(gifs: gifs) }

  before do
    allow(Tag).to receive(:find).with("tag123").and_return(tag)
  end

  it "returns http success" do
    get :show, id: "tag123"
    expect(response).to have_http_status(:success)
  end

  it "assigns the tag" do
    get :show, id: "tag123"
    expect(assigns(:tag)).to eql tag
  end

  it "assigns the tag's gifs" do
    get :show, id: "tag123"
    expect(assigns(:gifs)).to eql gifs
  end
end

RSpec.describe TagsController, '#create', type: :controller do
  let(:gif) { double(id: "gif123") }

  before do
    allow(Gif).to receive(:find) { gif }
    allow(gif).to receive(:tag!)
  end

  it "tags the gif" do
    expect(Gif).to receive(:find).with("gif123").and_return(gif)
    expect(gif).to receive(:tag!).with('tag-text')
    post :create, gif_id: 'gif123', tag: 'tag-text'
  end

  it "redirects to the gif" do
    post :create, gif_id: 'gif123', tag: 'tag-text'
    expect(response).to redirect_to gif_path(gif)
  end
end

RSpec.describe TagsController, '#destroy', type: :controller do
  let(:gif) { double(id: "gif123") }

  before do
    allow(Gif).to receive(:find) { gif }
    allow(gif).to receive(:untag!)
  end

  it "untags the gif" do
    expect(Gif).to receive(:find).with("gif123").and_return(gif)
    expect(gif).to receive(:untag!).with('123')
    delete :destroy, gif_id: 'gif123', id: 123
  end

  it "redirects to the gif" do
    delete :destroy, gif_id: 'gif123', id: 123
    expect(response).to redirect_to gif_path(gif)
  end
end

