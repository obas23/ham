require 'rails_helper'

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

RSpec.describe Tag, '#to_s' do
  it "returns its id in human readable form" do
    tag = Tag.create("a-nice-slugged-tag")
    expect(tag.to_s).to eql "a nice slugged tag"
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

RSpec.describe Tag, '.search' do
  before { clear_redis! }

  xit "returns tags matching the query" do
    tag1 = Tag.create "your awesome tag"
    tag2 = Tag.create "your"
    tag3 = Tag.create "awesome"
    tag4 = Tag.create "tag"

    expect(Tag.search('your')).to match_array [tag2, tag1]
    expect(Tag.search('awesome')).to match_array [tag3, tag1]
    expect(Tag.search('tag')).to match_array [tag4, tag1]
    expect(Tag.search('your awesome tag')).to match_array [tag1]
  end

  xit "returns no results if the query is nil" do
    expect(Tag.search(nil)).to match_array []
  end

  xit "returns no results if the query is too small" do
    tag = Tag.create 'abc'
    expect(Tag.search('')).to match_array []
    expect(Tag.search('a')).to match_array []
    expect(Tag.search('ab')).to match_array []
    expect(Tag.search('abc')).to match_array [tag]
  end

  xit "returns no results when there are no matching tags" do
    expect(Tag.search('wattt')).to match_array []
  end
end

