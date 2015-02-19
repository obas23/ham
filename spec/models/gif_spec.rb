require 'rails_helper'

RSpec.describe Gif, 'validations', type: :model do
  it "validates that it has an id" do
    gif_without_id = Gif.new id: nil
    expect(gif_without_id).to be_invalid

    gif_with_id = Gif.new id: "abc123"
    expect(gif_with_id).to be_valid
  end

  it "validates that the id is unique" do
    gif1 = Gif.create! id: "gif123"
    gif2 = Gif.new id: "GIF123"
    expect(gif2).to be_invalid
  end
end

RSpec.describe Gif, 'scopes', type: :model do
  it "orders them newest-first by default" do
    gif1 = Gif.create! id: "gif1"
    gif1.created_at = Date.today - 1.days
    gif1.save!

    gif2 = Gif.create! id: "gif2"
    gif2.created_at = Date.today - 2.days
    gif2.save!

    gif3 = Gif.create! id: "gif3"
    gif3.created_at = Date.today
    gif3.save!

    expect(Gif.all.map(&:id)).to eql [gif3.id, gif1.id, gif2.id]
  end
end

RSpec.describe Gif, '#tags', type: :model do
  it "returns its associated gifs" do
    tag1 = Tag.create! text: "tag1"
    tag2 = Tag.create! text: "tag2"
    tag3 = Tag.create! text: "tag3"

    gif = Gif.create! id: "gif123"
    gif.tags << tag1
    gif.tags << tag3

    gif = Gif.find(gif.id)
    expect(gif.tags).to include tag1
    expect(gif.tags).to_not include tag2
    expect(gif.tags).to include tag3
  end
end

RSpec.describe Gif, '#url', type: :model do
  it "returns its imgur url" do
    gif = Gif.create! id: "ZKy6vCD"
    expect(gif.url).to eql "http://i.imgur.com/ZKy6vCD.gif"
  end
end

RSpec.describe Gif, '#thumbnail_url', type: :model do
  it "returns its imgur thumbnail url" do
    gif = Gif.create! id: "ZKy6vCD"
    expect(gif.thumbnail_url).to eql "http://i.imgur.com/ZKy6vCDb.gif"
  end
end

RSpec.describe Gif, '#next', type: :model do
  it "returns the next gif" do
    gif1 = Gif.create! id: "gif1", created_at: Date.today
    gif2 = Gif.create! id: "gif2", created_at: Date.today + 1.day
    gif3 = Gif.create! id: "gif3", created_at: Date.today + 2.days
    expect(gif3.next).to eql gif2
    expect(gif2.next).to eql gif1
    expect(gif1.next).to eql nil
  end
end

RSpec.describe Gif, '#prev', type: :model do
  it "returns the previous gif" do
    gif1 = Gif.create! id: "gif1", created_at: Date.today
    gif2 = Gif.create! id: "gif2", created_at: Date.today + 1.day
    gif3 = Gif.create! id: "gif3", created_at: Date.today + 2.days
    expect(gif1.prev).to eql gif2
    expect(gif2.prev).to eql gif3
    expect(gif3.prev).to eql nil
  end
end


