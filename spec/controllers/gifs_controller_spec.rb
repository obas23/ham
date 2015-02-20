require 'rails_helper'

RSpec.describe GifsController, '#index', type: :controller do
  let(:all_gifs) { double }
  let(:matching_gifs) { double }

  before do
    allow(Gif).to receive(:all) { all_gifs }
    allow(Gif).to receive(:search).with('search term') { matching_gifs }
  end

  it "returns http success" do
    get :index
    expect(response).to have_http_status(:success)
  end

  context "when there is a query present" do
    it "assigns all gifs" do
      get :index
      expect(assigns(:gifs)).to eql all_gifs
    end
  end

  context "when there is not a query present" do
    it "assigns all gifs" do
      get :index, q: 'search term'
      expect(assigns(:gifs)).to eql matching_gifs
    end
  end
end

RSpec.describe GifsController, '#show', type: :controller do
  let(:gif) { double }

  before do
    allow(Gif).to receive(:find).with("gif123").and_return(gif)
  end

  it "returns http success" do
    get :show, id: "gif123"
    expect(response).to have_http_status(:success)
  end

  it "assigns the gif" do
    get :show, id: "gif123"
    expect(assigns(:gif)).to eql gif
  end
end

