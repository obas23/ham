require 'spec_helper'

RSpec.describe Tag, '.create' do
  it "lowercases the id" do
    tag = Tag.create("AbCdEfG")
    expect(tag.id).to eql "abcdefg"
  end

  it "strips strips and consolidates whitespace to dashes" do
    tag = Tag.create("  leading whitespace")
    expect(tag.id).to eql "leading-whitespace"

    tag = Tag.create("trailing whitespace     ")
    expect(tag.id).to eql "trailing-whitespace"

    tag = Tag.create("   leading and trailing whitespace   ")
    expect(tag.id).to eql "leading-and-trailing-whitespace"

    tag = Tag.create("has  internal    whitespace and 123 numbers and '%$&^ non-alphanumric")
    expect(tag.id).to eql "has-internal-whitespace-and-123-numbers-and-non-alphanumric"
  end
end

RSpec.describe Tag, '.retrieve' do
  before { clear_redis! }

  it "locates tags case insensitively" do
    tag = Tag.create("AbCdEfG")
    expect(Tag.retrieve("abcdefg")).to eq tag
  end

  it "locates tags uniformly" do
    tag = Tag.create("without-whitespace-and-junk")
    expect(Tag.retrieve("without    whitespace and junk")).to eq tag
  end
end

RSpec.describe Tag, '.search' do
  before { clear_redis! }

  it "returns tags matching the query" do
    tag1 = Tag.create "your awesome tag"
    tag2 = Tag.create "your"
    tag3 = Tag.create "awesome"
    tag4 = Tag.create "tag"

    expect(Tag.search('your awesome tag')).to match_array [tag1, tag3, tag2, tag4]
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

RSpec.describe Tag, '.complete' do
  before { clear_redis! }

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


RSpec.describe Tag, '#text' do
  it "returns its id in human readable form" do
    tag = Tag.create("a-nice-slugged-tag")
    expect(tag.text).to eql "a nice slugged tag"
  end
end

RSpec.describe Tag, '#to_s' do
  it "returns its text" do
    tag = Tag.create("a-nice-slugged-tag")
    expect(tag).to receive(:text).and_return("tag text")
    expect(tag.to_s).to eql "tag text"
  end
end

RSpec.describe Tag, '#attributes' do
  let(:tag) { Tag.create("My Custom Tag") }

  it "returns its attributes as a hash" do
    hash = {
      id: "my-custom-tag",
      text: "my custom tag"
    }
    expect(tag.attributes).to eql hash
  end
end

RSpec.describe Tag, '#gifs' do
  before { clear_redis! }

  it "returns its associated gifs" do
    gif1 = Gif.create "gif1"
    gif2 = Gif.create "gif2"
    gif3 = Gif.create "gif3"

    gif1.tag! "mytag"
    gif2.tag! "mytag"
    gif3.tag! "mytag"

    tag = Tag.retrieve("mytag")
    expect(tag.gifs.map(&:id)).to include "gif1"
    expect(tag.gifs.map(&:id)).to include "gif2"
    expect(tag.gifs.map(&:id)).to include "gif3"
  end
end

