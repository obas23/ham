require 'rails_helper'

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

