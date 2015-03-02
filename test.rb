require 'net/http'
require 'json'
require 'uri'
require 'redis'
require 'colored'

redis = Redis.new(url: "redis://localhost:6379/2")
keys = redis.keys('*')
redis.del(*keys) if keys.any?

class NotEqlError < StandardError
  attr_reader :got, :expected
  def initialize(got, expected)
    @got = got
    @expected = expected
  end
end

class Suite
  def self.run(&block)
    suite = new(block)

    STDOUT.sync

    begin
      # Start the app in test mode, daemonized
      %x[ENV=test REDIS_URL=redis://localhost:6379/2 PORT=9293 ./start]

      # Give the app some time to boot
      sleep 1

      suite.run!
    ensure
      # Always stop the app
      %x[ENV=test REDIS_URL=redis://localhost:6379/2 PORT=9293 ./stop]
    end
  end

  def initialize(block)
    @runnable = block
  end

  def run!
    instance_eval &@runnable
  end

  def get(url)
    print "#{'GET'.ljust(7).blue} #{url.ljust(36)}"
    uri = URI.parse("http://localhost:9293#{url}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    json = JSON.parse(response.body)
    status = response.code.to_i
    wrap_assertions do
      yield json, status
    end
    return json, status
  end

  def post(url, params)
    print "#{'POST'.ljust(7).blue} #{url.ljust(36)}"
    headers = {"Content-Type" => "application/json", "Accept" => "application/json"}
    uri = URI.parse("http://localhost:9293#{url}")
    response = Net::HTTP.post_form(uri, params)
    json = JSON.parse(response.body)
    status = response.code.to_i
    wrap_assertions do
      yield json, status
    end
    return json, status
  end

  def delete(url)
    print "#{'DELETE'.ljust(7).blue} #{url.ljust(36)}"
    uri = URI.parse("http://localhost:9293#{url}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Delete.new(uri.request_uri)
    response = http.request(request)
    json = JSON.parse(response.body)
    status = response.code.to_i
    wrap_assertions do
      yield json, status
    end
    return json, status
  end

  def wrap_assertions
    begin
      yield
    rescue NotEqlError => e
      puts "FAIL".red
      puts
      puts "Expected: #{e.expected}"
      puts "     Got: #{e.got}"
      puts
      exit
    else
      puts "SUCCESS".green
    end
  end

  def assert_eql(a, b)
    raise NotEqlError.new(a, b) unless a == b
  end
end

Suite.run do
  get("/api/gifs") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [])
  end

  post("/api/gifs", { gif: "abc123" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "abc123",
      "url" => "http://i.imgur.com/abc123.gif",
      "thumbnail_url" => "http://i.imgur.com/abc123b.gif"
    })
  end

  get("/api/gifs") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "abc123",
      "url" => "http://i.imgur.com/abc123.gif",
      "thumbnail_url" => "http://i.imgur.com/abc123b.gif"
    }])
  end

  get("/api/gifs/abc123") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, {
      "id" => "abc123",
      "url" => "http://i.imgur.com/abc123.gif",
      "thumbnail_url" => "http://i.imgur.com/abc123b.gif"
    })
  end

  post("/api/gifs", { gif: "xyz456" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "xyz456",
      "url" => "http://i.imgur.com/xyz456.gif",
      "thumbnail_url" => "http://i.imgur.com/xyz456b.gif"
    })
  end

  get("/api/gifs") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "xyz456",
      "url" => "http://i.imgur.com/xyz456.gif",
      "thumbnail_url" => "http://i.imgur.com/xyz456b.gif"
    }, {
      "id" => "abc123",
      "url" => "http://i.imgur.com/abc123.gif",
      "thumbnail_url" => "http://i.imgur.com/abc123b.gif"
    }])
  end

  get("/api/gifs/xyz456") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, {
      "id" => "xyz456",
      "url" => "http://i.imgur.com/xyz456.gif",
      "thumbnail_url" => "http://i.imgur.com/xyz456b.gif"
    })
  end

  get("/api/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [])
  end

  post("/api/gifs/abc123/tags", { tag: "Shared Tag" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "shared-tag",
      "text" => "shared tag"
    })
  end

  post("/api/gifs/abc123/tags", { tag: "Custom Tag 1" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    })
  end

  post("/api/gifs/xyz456/tags", { tag: "Shared Tag" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "shared-tag",
      "text" => "shared tag"
    })
  end

  post("/api/gifs/xyz456/tags", { tag: "Custom Tag 2" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "custom-tag-2",
      "text" => "custom tag 2"
    })
  end

  get("/api/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "custom-tag-2",
      "text" => "custom tag 2"
    }, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    }, {
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/gifs/abc123/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    }, {
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/gifs/xyz456/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "custom-tag-2",
      "text" => "custom tag 2"
    }, {
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/tags?q=shared") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/tags/complete?q=cust") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "custom-tag-2",
      "text" => "custom tag 2"
    }, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    }])
  end

  delete("/api/gifs/abc123/tags/custom-tag-1") do |json, status|
    assert_eql(status, 202)
    assert_eql(json, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    })
  end

  get("/api/gifs/abc123/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/gifs?q=shared") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "xyz456",
      "url" => "http://i.imgur.com/xyz456.gif",
      "thumbnail_url" => "http://i.imgur.com/xyz456b.gif"
    }, {
      "id" => "abc123",
      "url" => "http://i.imgur.com/abc123.gif",
      "thumbnail_url" => "http://i.imgur.com/abc123b.gif"
    }])
  end

  get("/api/gifs?q=custom") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "xyz456",
      "url" => "http://i.imgur.com/xyz456.gif",
      "thumbnail_url" => "http://i.imgur.com/xyz456b.gif"
    }])
  end
end


