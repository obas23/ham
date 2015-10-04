require 'spec_helper'

module Ham
  describe Tag, '.create' do
    before { reset_db! }
    it "normalizes the tag" do
      tag = Tag.create("AbCdEfG")
      expect(tag.id).to eql "abcdefg"

      tag = Tag.create("  leading whitespace")
      expect(tag.id).to eql "leading-whitespace"

      tag = Tag.create("trailing whitespace     ")
      expect(tag.id).to eql "trailing-whitespace"

      tag = Tag.create("   leading and trailing whitespace   ")
      expect(tag.id).to eql "leading-and-trailing-whitespace"

      tag = Tag.create("has  internal    whitespace and 123 numbers and '%$&^ non alphanumric")
      expect(tag.id).to eql "has-internal-whitespace-and-123-numbers-and-non-alphanumric"
    end
  end

  describe Tag, '.all' do
    before { reset_db! }

    it "returns all tags ordered newest first" do
      tag1 = Tag.create "tag1"
      tag2 = Tag.create "tag2"
      tag3 = Tag.create "tag3"
      expect(Tag.all).to match_array [tag1, tag2, tag3]
    end
  end

  describe Tag, '.find' do
    before { reset_db! }

    it "locates tags uniformly" do
      tag = Tag.create("AbCdEfG")
      expect(Tag.find("abcdefg")).to eq tag

      tag = Tag.create("without whitespace and junk")
      expect(Tag.find("without    whitespace and junk")).to eq tag
    end

    it "raises when the tag does not exist" do
      expect {
        Tag.find("nonexistent-tag")
      }.to raise_exception Tag::NotFound
    end
  end

  describe Tag, '.search' do
    before { reset_db! }

    it "returns tags matching the query" do
      tag1 = Tag.create "your awesome tag"
      tag2 = Tag.create "your"
      tag3 = Tag.create "awesome"
      tag4 = Tag.create "tag"

      expect(Tag.search('your awesome tag')).to match_array [tag1]
      expect(Tag.search('your')).to             match_array [tag1, tag2]
      expect(Tag.search('awesome')).to          match_array [tag1, tag3]
      expect(Tag.search('tag')).to              match_array [tag1, tag4]
    end

    it "returns all tags when the query is nil or empty" do
      tag1 = Tag.create "tag1"
      tag2 = Tag.create "tag2"
      tag3 = Tag.create "tag3"
      expect(Tag.search(nil)).to match_array  [tag1, tag2, tag3]
      expect(Tag.search('')).to match_array   [tag1, tag2, tag3]
      expect(Tag.search('  ')).to match_array [tag1, tag2, tag3]
    end

    it "returns no results when there are no matching tags" do
      expect(Tag.search('wattt')).to match_array []
    end
  end

  describe Tag, '.complete' do
    before { reset_db! }

    it "returns tags starting with the query" do
      tag1 = Tag.create "my awesome tag"
      tag2 = Tag.create "your awesome tag"
      tag3 = Tag.create "another awesome tag"

      expect(Tag.complete('my')).to                       match_array [tag1]
      expect(Tag.complete('my awesome')).to               match_array [tag1]
      expect(Tag.complete('my awesome ta')).to            match_array [tag1]
      expect(Tag.complete('my awesome tag')).to           match_array [tag1]
      expect(Tag.complete('my awesome tag with')).to      match_array []

      expect(Tag.complete('your')).to                     match_array [tag2]
      expect(Tag.complete('your awesome')).to             match_array [tag2]
      expect(Tag.complete('your awesome ta')).to          match_array [tag2]
      expect(Tag.complete('your awesome tag')).to         match_array [tag2]
      expect(Tag.complete('your awesome tag with')).to    match_array []

      expect(Tag.complete('another')).to                  match_array [tag3]
      expect(Tag.complete('another awesome')).to          match_array [tag3]
      expect(Tag.complete('another awesome ta')).to       match_array [tag3]
      expect(Tag.complete('another awesome tag')).to      match_array [tag3]
      expect(Tag.complete('another awesome tag with')).to match_array []
    end
  end

  describe Tag, '.gifs' do
    before { reset_db! }

    it "returns associated gifs" do
      tag = Tag.create("mytag")

      gif1 = Gif.create "gif1"
      gif2 = Gif.create "gif2"
      gif3 = Gif.create "gif3"

      Gif.tag(gif1.id, tag.id)
      Gif.tag(gif2.id, tag.id)
      Gif.tag(gif3.id, tag.id)

      expect(Tag.gifs(tag.id)).to include gif1
      expect(Tag.gifs(tag.id)).to include gif2
      expect(Tag.gifs(tag.id)).to include gif3
    end
  end

  describe Tag, '#text' do
    it "returns its id in human-readable format" do
      tag = Tag.new("my-custom-tag")
      expect(tag.text).to eq "my custom tag"
    end
  end

  describe Tag, '#attributes' do
    it "returns its attributes as a hash" do
      tag = Tag.create("My Custom Tag")
      hash = {
        id: "my-custom-tag",
        text: "my custom tag"
      }
      expect(tag.attributes).to eq hash
    end
  end

  describe Tag, '#gifs' do
    before { reset_db! }

    it "returns its gifs" do
      tag1 = Tag.create "tag1"
      gif1, gif2 = double, double
      expect(Tag).to receive(:gifs).with("tag1").and_return([gif1, gif2])
      expect(tag1.gifs).to match_array [gif1, gif2]
    end
  end
end
