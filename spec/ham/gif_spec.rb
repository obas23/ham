require 'spec_helper'

module Ham
  describe Gif, '.search' do
    before { clear_redis! }

    it "returns gifs matching the query" do
      blue_tag = Tag.create "blue"
      red_tag  = Tag.create "red"

      blue_gif = Gif.create "blue_gif"
      Gif.tag(blue_gif, blue_tag)

      red_gif = Gif.create "red_gif"
      Gif.tag(red_gif, red_tag)

      blue_and_red_gif = Gif.create "blue_and_red_gif"
      Gif.tag(blue_and_red_gif, blue_tag)
      Gif.tag(blue_and_red_gif, red_tag)

      expect(Gif.search("blue")).to   match_array [blue_and_red_gif, blue_gif]
      expect(Gif.search("red")).to    match_array [blue_and_red_gif, red_gif]
      expect(Gif.search("purple")).to match_array []
    end

    it "returns all gifs when the query is nil or empty" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"

      expect(Gif.search(nil)).to match_array  [gif1, gif2, gif3]
      expect(Gif.search('')).to match_array   [gif1, gif2, gif3]
      expect(Gif.search('  ')).to match_array [gif1, gif2, gif3]
    end
  end

  describe Gif, '.tag' do
    before { clear_redis! }

    it "associates the tag with the gif" do
      Gif.create("gif123")
      Gif.tag("gif123", "tag123")

      gif = Gif.find("gif123")
      expect(gif.tags.map(&:id)).to include "tag123"

      tag = Tag.find("tag123")
      expect(tag.gifs.map(&:id)).to include "gif123"
    end

    it "doesn't add the tag when it already has it" do
      Gif.create("gif123")
      Gif.tag("gif123", "tag123")

      gif = Gif.find("gif123")

      expect {
        Gif.tag("gif123", "tag123")
        Gif.tag("gif123", "tag123")
        Gif.tag("gif123", "tag123")
      }.to change(gif.tags, :count).by(0)
    end

    it "returns the tag" do
      Gif.create("gif123")
      tag = Gif.tag("gif123", "tag123")
      expect(tag.id).to eql "tag123"
    end

    it "accepts gif and tag models" do
      gif = Gif.create("gif123")
      tag = Tag.create("tag123")

      Gif.tag(gif, tag)

      expect(gif.tags.map(&:id)).to include "tag123"
      expect(tag.gifs.map(&:id)).to include "gif123"
    end
  end

  describe Gif, '.untag' do
    before { clear_redis! }

    it "removes the tag from the gif" do
      gif = Gif.create("gif123")
      tag = Tag.create("tag123")

      Gif.tag "gif123", "tag123"

      expect(gif.tags.map(&:id)).to include "tag123"
      expect(tag.gifs.map(&:id)).to include "gif123"

      Gif.untag "gif123", "tag123"

      expect(gif.tags.map(&:id)).not_to include "tag123"
      expect(tag.gifs.map(&:id)).not_to include "gif123"
    end

    it "returns the tag" do
      Gif.create("gif123")
      Tag.create("tag123")
      tag = Gif.untag("gif123", "tag123")
      expect(tag.id).to eql "tag123"
    end

    it "accepts gif and tag models" do
      gif = Gif.create("gif123")
      tag = Tag.create("tag123")

      Gif.untag(gif, tag)

      expect(gif.tags.map(&:id)).not_to include "tag123"
      expect(tag.gifs.map(&:id)).not_to include "gif123"
    end
  end

  describe Gif, '#tags' do
    before { clear_redis! }

    it "returns its tags" do
      gif  = Gif.create("gif123")

      tag1 = Tag.create("tag1")
      tag2 = Tag.create("tag2")
      tag3 = Tag.create("tag3")

      Gif.tag(gif, tag1)
      Gif.tag(gif, tag2)
      Gif.tag(gif, tag3)

      expect(gif.tags).to match_array [tag1, tag2, tag3]
    end
  end

  describe Gif, '#url' do
    before { clear_redis! }

    it "returns its imgur url" do
      gif = Gif.new "ZKy6vCD"
      expect(gif.url).to eql "http://i.imgur.com/ZKy6vCD.gif"
    end
  end

  describe Gif, '#thumbnail_url' do
    before { clear_redis! }

    it "returns its imgur thumbnail url" do
      gif = Gif.new "ZKy6vCD"
      expect(gif.thumbnail_url).to eql "http://i.imgur.com/ZKy6vCDb.gif"
    end
  end

  describe Gif, '#attributes' do
    let(:gif) { Gif.create("gif123") }

    it "returns its attributes as a hash" do
      hash = {
        id: "gif123",
        url: "http://i.imgur.com/gif123.gif",
        thumbnail_url: "http://i.imgur.com/gif123b.gif"
      }

      expect(gif.attributes).to eql hash
    end
  end
end

