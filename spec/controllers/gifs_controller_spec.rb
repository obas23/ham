require 'rails_helper'

RSpec.describe GifsController, type: :controller do

  describe "GET #index" do
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

end
