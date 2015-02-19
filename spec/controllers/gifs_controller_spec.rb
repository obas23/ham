require 'rails_helper'

RSpec.describe GifsController, '#index', type: :controller do
  let(:gifs) { double }

  before do
    allow(Gif).to receive(:all) { gifs }
  end

  it "returns http success" do
    get :index
    expect(response).to have_http_status(:success)
  end

  it "assigns all gifs" do
    get :index
    expect(assigns(:gifs)).to eql gifs
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

