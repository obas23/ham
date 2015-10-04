require 'spec_helper'

module Ham
  describe Gif, '.create' do
    before { reset_db! }

    it "returns a new instance of the class" do
      gif = Gif.create "abc123"
      expect(gif).to be_instance_of Gif
    end

    it "does not create duplicates" do
      expect(Ham.db.count('gifs')).to eql 0
      Gif.create "abc123"
      Gif.create "abc123"
      Gif.create "abc123"
      expect(Ham.db.count('gifs')).to eql 1
    end
  end

  describe Gif, '.all' do
    before { reset_db! }

    it "returns all gifs ordered newest first" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"
      expect(Gif.all).to match_array [gif1, gif2, gif3]
    end
  end

  describe Gif, '.find' do
    before { reset_db! }

    it "returns the gif" do
      gif1 = Gif.create "gif1"
      expect(Gif.find("gif1")).to eq gif1
    end

    it "raises when the gif does not exist" do
      expect {
        Gif.find("nonexistent-gif")
      }.to raise_exception Gif::NotFound
    end
  end

  describe Gif, '.first' do
    before { reset_db! }

    it "returns the first element sorted by date desc" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"
      expect(Gif.first).to eq gif3
    end

    it "returns nil if there are no records" do
      expect(Gif.first).to eq nil
    end
  end

  describe Gif, '.last' do
    before { reset_db! }

    it "returns the first element sorted by date asc" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"
      expect(Gif.last).to eq gif1
    end

    it "returns nil if there are no records" do
      expect(Gif.last).to eq nil
    end
  end

  describe Gif, '.next' do
    before { reset_db! }

    it "returns the next model" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"
      expect(Gif.next("gif3")).to eq gif2
      expect(Gif.next("gif2")).to eq gif1
      expect(Gif.next("gif1")).to eq gif3
    end
  end

  describe Gif, '.prev' do
    before { reset_db! }

    it "returns the previous model" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"
      expect(Gif.prev("gif1")).to eq gif2
      expect(Gif.prev("gif2")).to eq gif3
      expect(Gif.prev("gif3")).to eq gif1
    end
  end

  describe Gif, '.tags' do
    before { reset_db! }

    it "returns associated tags" do
      gif  = Gif.create("gif123")

      tag1 = Tag.create("tag1")
      tag2 = Tag.create("tag2")
      tag3 = Tag.create("tag3")

      Gif.tag(gif.id, tag1.id)
      Gif.tag(gif.id, tag2.id)
      Gif.tag(gif.id, tag3.id)

      expect(Gif.tags(gif.id)).to match_array [tag1, tag2, tag3]
    end
  end

  describe Gif, '.tag' do
    before { reset_db! }

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
  end

  describe Gif, '.untag' do
    before { reset_db! }

    it "removes the tag from the gif" do
      gif = Gif.create("gif123")
      tag = Tag.create("tag123")

      Gif.tag "gif123", "tag123"

      expect(gif.tags.map(&:id)).to include "tag123"
      expect(tag.gifs.map(&:id)).to include "gif123"

      Gif.untag "gif123", "tag123"

      expect(Gif.find(gif.id).tags.map(&:id)).not_to include "tag123"
      expect(Tag.find(tag.id).gifs.map(&:id)).not_to include "gif123"
    end
  end

  describe Gif, '.search' do
    before { reset_db! }

    it "returns gifs matching the query" do
      blue_tag = Tag.create "blue"
      red_tag  = Tag.create "red"

      blue_gif = Gif.create "blue_gif"
      Gif.tag(blue_gif.id, blue_tag.id)

      red_gif = Gif.create "red_gif"
      Gif.tag(red_gif.id, red_tag.id)

      blue_and_red_gif = Gif.create "blue_and_red_gif"
      Gif.tag(blue_and_red_gif.id, blue_tag.id)
      Gif.tag(blue_and_red_gif.id, red_tag.id)

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

  describe Gif, '#next' do
    before { reset_db! }

    it "returns the next model" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      expect(Gif).to receive(:next).with("gif1").and_return(gif2)
      expect(gif1.next).to eq gif2
    end
  end

  describe Gif, '#prev' do
    before { reset_db! }

    it "returns the previous model" do
      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      expect(Gif).to receive(:prev).with("gif2").and_return(gif1)
      expect(gif2.prev).to eq gif1
    end
  end

  describe Gif, '#url' do
    before { reset_db! }

    it "returns its imgur url" do
      gif = Gif.new "ZKy6vCD"
      expect(gif.url).to eql "http://i.imgur.com/ZKy6vCD.gif"
    end
  end

  describe Gif, '#thumbnail_url' do
    before { reset_db! }

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

  describe Gif, '#tags' do
    before { reset_db! }

    it "returns its tags" do
      gif1 = Gif.create "gif1"
      tag1, tag2 = double, double
      expect(Gif).to receive(:tags).with("gif1").and_return([tag1, tag2])
      expect(gif1.tags).to match_array [tag1, tag2]
    end
  end
end

