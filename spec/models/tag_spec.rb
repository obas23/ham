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

