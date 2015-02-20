require 'rails_helper'

RSpec.describe Tag, 'validations', type: :model do
  it "validates that is has text" do
    tag_without_text = Tag.new text: nil
    expect(tag_without_text).to be_invalid

    tag_with_text = Tag.new text: "my text"
    expect(tag_with_text).to be_valid
  end

  it "validates that the text is unique" do
    tag1 = Tag.create! text: "my awesome tag"
    tag2 = Tag.new text: "My Awesome Tag"
    expect(tag2).to be_invalid
  end
end

RSpec.describe Tag, '#text=', type: :model do
  it "lowercases the text" do
    tag = Tag.new
    tag.text = "AbCdEfG"
    expect(tag.text).to eql "abcdefg"
  end

  it "strips leading and trailing whitespace" do
    tag = Tag.new
    tag.text = "  leading whitespace"
    expect(tag.text).to eql "leading whitespace"

    tag.text = "trailing whitespace     "
    expect(tag.text).to eql "trailing whitespace"

    tag.text = "   leading and trailing whitespace   "
    expect(tag.text).to eql "leading and trailing whitespace"
  end
end

RSpec.describe Tag, '#gifs', type: :model do
  it "returns its associated gifs" do
    gif1 = Gif.create! id: "gif1"
    gif2 = Gif.create! id: "gif2"
    gif3 = Gif.create! id: "gif3"

    tag = Tag.create! text: "my tag"
    tag.gifs << gif1
    tag.gifs << gif3

    tag = Tag.find(tag.id)
    expect(tag.gifs).to include gif1
    expect(tag.gifs).to_not include gif2
    expect(tag.gifs).to include gif3
  end
end

RSpec.describe Tag, '.search', type: :model do
  before do
    Tag.delete_all
  end

  it "returns tags matching the query" do
    tag1 = Tag.create! text: "your awesome tag"
    tag2 = Tag.create! text: "your"
    tag3 = Tag.create! text: "awesome"
    tag4 = Tag.create! text: "tag"

    expect(Tag.search('your')).to match_array [tag2, tag1]
    expect(Tag.search('awesome')).to match_array [tag3, tag1]
    expect(Tag.search('tag')).to match_array [tag4, tag1]
    expect(Tag.search('your awesome tag')).to match_array [tag1]
  end

  it "returns no results if the query is nil" do
    expect(Tag.search(nil)).to match_array []
  end

  it "returns no results if the query is too small" do
    tag = Tag.create! text: 'abc'
    expect(Tag.search('')).to match_array []
    expect(Tag.search('a')).to match_array []
    expect(Tag.search('ab')).to match_array []
    expect(Tag.search('abc')).to match_array [tag]
  end

  it "returns no results when there are no matching tags" do
    expect(Tag.search('wattt')).to match_array []
  end
end

