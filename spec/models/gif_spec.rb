require 'rails_helper'

RSpec.describe Gif, '.search' do
  before { clear_redis! }

  it "returns gifs matching the query" do
    blue_tag = Tag.create "blue", Date.today
    red_tag  = Tag.create "red",  Date.today + 1.hour

    blue_gif = Gif.create "blue_gif"
    blue_gif.tag! "blue"

    red_gif = Gif.create "red_gif"
    red_gif.tag! "red"

    blue_and_red_gif = Gif.create "blue_and_red_gif"
    blue_and_red_gif.tag! "blue"
    blue_and_red_gif.tag! "red"

    expect(Gif.search("blue")).to   match_array [blue_and_red_gif, blue_gif]
    expect(Gif.search("red")).to    match_array [blue_and_red_gif, red_gif]
    expect(Gif.search("purple")).to match_array []
  end
end

RSpec.describe Gif, '#tags' do
  before { clear_redis! }

  it "returns its tags" do
    gif = Gif.create("gif123")
    tag1, tag2, tag3 = double, double, double

    expect($redis).to receive(:smembers).with("gif:gif123:tags").and_return(["tag1", "tag2", "tag3"])
    allow(Tag).to receive(:new).with("tag1").and_return(tag1)
    allow(Tag).to receive(:new).with("tag2").and_return(tag2)
    allow(Tag).to receive(:new).with("tag3").and_return(tag3)

    expect(gif.tags).to match_array [tag1, tag2, tag3]
  end
end

RSpec.describe Gif, 'tag!' do
  before { clear_redis! }

  it "associates the tag with the gif" do
    clear_redis!
    gif = Gif.create("gif123")
    gif.tag! "tag123"
    expect(gif.tags.map(&:id)).to include "tag123"

    tag = Tag.retrieve("tag123")
    expect(tag.gifs.map(&:id)).to include "gif123"
  end

  it "doesn't add the tag when it already has it" do
    gif = Gif.create("gif123")
    gif.tag! "tag123"

    expect {
      gif.tag! "tag123"
      gif.tag! "tag123"
      gif.tag! "tag123"
    }.to change(gif.tags, :count).by(0)
  end
end

RSpec.describe Gif, 'untag!' do
  before { clear_redis! }

  it "removes the tag" do
    gif = Gif.create("gif123")
    gif.tag! "tag123"

    gif = Gif.retrieve("gif123")
    tag = Tag.retrieve("tag123")
    expect(gif.tags.map(&:id)).to include "tag123"
    expect(tag.gifs.map(&:id)).to include "gif123"
    gif.untag! "tag123"

    gif = Gif.retrieve("gif123")
    tag = Tag.retrieve("tag123")
    expect(gif.tags.map(&:id)).not_to include "tag123"
    expect(tag.gifs.map(&:id)).not_to include "gif123"
  end
end

RSpec.describe Gif, '#url' do
  before { clear_redis! }

  it "returns its imgur url" do
    gif = Gif.new "ZKy6vCD"
    expect(gif.url).to eql "http://i.imgur.com/ZKy6vCD.gif"
  end
end

RSpec.describe Gif, '#thumbnail_url' do
  before { clear_redis! }

  it "returns its imgur thumbnail url" do
    gif = Gif.new "ZKy6vCD"
    expect(gif.thumbnail_url).to eql "http://i.imgur.com/ZKy6vCDb.gif"
  end
end

RSpec.describe Gif, '#synced?' do
  let(:gif)      { Gif.create("gif123") }
  let(:uri)      { double(host: "host", port: "port", request_uri: "request_uri") }
  let(:http)     { double }
  let(:request)  { double }
  let(:response) { double }

  before do
    allow(URI).to receive(:parse).with(gif.url).and_return(uri)
    allow(Net::HTTP).to receive(:new).with("host", "port").and_return(http)
    allow(Net::HTTP::Head).to receive(:new).with("request_uri").and_return(request)
    allow(http).to receive(:request).with(request).and_return(response)
  end

  it "returns true when the image exists on Imgur" do
    expect(response).to receive(:instance_of?).with(Net::HTTPOK).and_return(true)
    expect(gif.synced?).to eql true
  end

  it "returns false when the image does not exist on Imgur" do
    expect(response).to receive(:instance_of?).with(Net::HTTPOK).and_return(false)
    expect(gif.synced?).to eql false
  end
end

