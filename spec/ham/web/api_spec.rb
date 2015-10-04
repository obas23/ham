require 'spec_helper'

describe Ham::Web::API do
  before { reset_db! }

  it "integrates" do
    get "/gifs"
    expect(status).to eq 200
    expect(body).to match_json({
      gifs: []
    })

    get "/gifs/gif1"
    expect(status).to eq 404
    expect(body).to match_json({
      error: { message: "Not Found" }
    })

    post "/gifs", { gif: "gif1" }
    expect(status).to eq 201
    expect(body).to match_json({
      gif: {
        id: "gif1",
        url: "http://i.imgur.com/gif1.gif",
        thumbnail_url: "http://i.imgur.com/gif1b.gif"
      }
    })

    get "/gifs"
    expect(status).to eq 200
    expect(body).to match_json({
      gifs: [{
        id: "gif1",
        url: "http://i.imgur.com/gif1.gif",
        thumbnail_url: "http://i.imgur.com/gif1b.gif"
      }]
    })

    get "/gifs/gif1"
    expect(status).to eq 200
    expect(body).to match_json({
      gif: {
        id: "gif1",
        url: "http://i.imgur.com/gif1.gif",
        thumbnail_url: "http://i.imgur.com/gif1b.gif"
      }
    })

    post "/gifs", { gif: "gif2" }
    expect(status).to eq 201
    expect(body).to match_json({
      gif: {
        id: "gif2",
        url: "http://i.imgur.com/gif2.gif",
        thumbnail_url: "http://i.imgur.com/gif2b.gif"
      }
    })

    get "/gifs"
    expect(status).to eq 200
    expect(body).to match_json({
      gifs: [{
        id: "gif2",
        url: "http://i.imgur.com/gif2.gif",
        thumbnail_url: "http://i.imgur.com/gif2b.gif"
      }, {
        id: "gif1",
        url: "http://i.imgur.com/gif1.gif",
        thumbnail_url: "http://i.imgur.com/gif1b.gif"
      }]
    })

    get "/gifs/gif2"
    expect(status).to eq 200
    expect(body).to match_json({
      gif: {
        id: "gif2",
        url: "http://i.imgur.com/gif2.gif",
        thumbnail_url: "http://i.imgur.com/gif2b.gif"
      }
    })

    get "/tags"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: []
    })

    post "/gifs/gif1/tags", { tag: "Shared Tag" }
    expect(status).to eq 201
    expect(body).to match_json({
      tag: {
        id: "shared-tag",
        text: "shared tag"
      }
    })

    post "/gifs/gif1/tags", { tag: "Custom Tag 1" }
    expect(status).to eq 201
    expect(body).to match_json({
      tag: {
        id: "custom-tag-1",
        text: "custom tag 1"
      }
    })

    post "/gifs/gif2/tags", { tag: "Shared Tag" }
    expect(status).to eq 201
    expect(body).to match_json({
      tag: {
        id: "shared-tag",
        text: "shared tag"
      }
    })

    post "/gifs/gif2/tags", { tag: "Custom Tag 2" }
    expect(status).to eq 201
    expect(body).to match_json({
      tag: {
        id: "custom-tag-2",
        text: "custom tag 2"
      }
    })

    get "/tags"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: [{
        id: "shared-tag",
        text: "shared tag"
      }, {
        id: "custom-tag-1",
        text: "custom tag 1"
      }, {
        id: "custom-tag-2",
        text: "custom tag 2"
      }]
    })

    get "/gifs/gif1/tags"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: [{
        id: "shared-tag",
        text: "shared tag"
      }, {
        id: "custom-tag-1",
        text: "custom tag 1"
      }]
    })

    get "/gifs/gif2/tags"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: [{
        id: "shared-tag",
        text: "shared tag"
      }, {
        id: "custom-tag-2",
        text: "custom tag 2"
      }]
    })

    get "/tags?q=shared"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: [{
        id: "shared-tag",
        text: "shared tag"
      }]
    })

    get "/tags/complete?q=cust"
    expect(status).to eq 200
    expect(body).to match_json({
      tags:[{
        id: "custom-tag-1",
        text: "custom tag 1"
      }, {
        id: "custom-tag-2",
        text: "custom tag 2"
      }]
    })

    delete "/gifs/gif1/tags/custom-tag-1"
    expect(status).to eq 202
    expect(body).to match_json({
      tag: {
        id: "custom-tag-1",
        text: "custom tag 1"
      }
    })

    get "/gifs/gif1/tags"
    expect(status).to eq 200
    expect(body).to match_json({
      tags: [{
        id: "shared-tag",
        text: "shared tag"
      }]
    })

    get "/gifs?q=shared"
    expect(status).to eq 200
    expect(body).to match_json({
      gifs: [{
        id: "gif1",
        url: "http://i.imgur.com/gif1.gif",
        thumbnail_url: "http://i.imgur.com/gif1b.gif"
      },{
        id: "gif2",
        url: "http://i.imgur.com/gif2.gif",
        thumbnail_url: "http://i.imgur.com/gif2b.gif"
      }]
    })

    get "/gifs?q=custom"
    expect(status).to eq 200
    expect(body).to match_json({
      gifs: [{
        id: "gif2",
        url: "http://i.imgur.com/gif2.gif",
        thumbnail_url: "http://i.imgur.com/gif2b.gif"
      }]
    })
  end
end

