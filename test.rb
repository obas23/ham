require 'net/http'
require 'json'
require 'uri'
require 'redis'
require 'colored'

REDIS_URL="redis://localhost:6379/2"
PORT=9293

class NotEqlError < StandardError
  attr_reader :got, :expected
  def initialize(got, expected)
    @got = got
    @expected = expected
  end
end

class Suite
  def self.run(&block)
    suite = new("http://localhost:#{PORT}", block)

    STDOUT.sync

    # Clear out Redis
    redis = Redis.new(url: REDIS_URL)
    keys = redis.keys('*')
    redis.del(*keys) if keys.any?

    begin
      # Start the app in test mode, daemonized
      %x[ENV=test REDIS_URL=#{REDIS_URL} PORT=#{PORT} ./start]

      # Give the app some time to boot
      sleep 1

      suite.run!
    ensure
      # Always stop the app
      %x[ENV=test REDIS_URL=#{REDIS_URL} PORT=#{PORT} ./stop]
    end
  end

  attr_reader :base_url

  def initialize(base_url, block)
    @base_url = base_url
    @runnable = block
  end

  def run!
    instance_eval &@runnable
  end

  def get(url)
    print "#{'GET'.ljust(7).blue} #{url.ljust(36)}"
    uri = URI.parse("#{base_url}#{url}")
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
    uri = URI.parse("#{base_url}#{url}")
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
    uri = URI.parse("#{base_url}#{url}")
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

  get("/api/gifs/gif1") do |json, status|
    assert_eql(status, 404)
    assert_eql(json, {
      "error" => { "message" => "Not Found" }
    })
  end

  post("/api/gifs", { gif: "gif1" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "gif1",
      "url" => "http://i.imgur.com/gif1.gif",
      "thumbnail_url" => "http://i.imgur.com/gif1b.gif"
    })
  end

  get("/api/gifs") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "gif1",
      "url" => "http://i.imgur.com/gif1.gif",
      "thumbnail_url" => "http://i.imgur.com/gif1b.gif"
    }])
  end

  get("/api/gifs/gif1") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, {
      "id" => "gif1",
      "url" => "http://i.imgur.com/gif1.gif",
      "thumbnail_url" => "http://i.imgur.com/gif1b.gif"
    })
  end

  post("/api/gifs", { gif: "gif2" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "gif2",
      "url" => "http://i.imgur.com/gif2.gif",
      "thumbnail_url" => "http://i.imgur.com/gif2b.gif"
    })
  end

  get("/api/gifs") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "gif2",
      "url" => "http://i.imgur.com/gif2.gif",
      "thumbnail_url" => "http://i.imgur.com/gif2b.gif"
    }, {
      "id" => "gif1",
      "url" => "http://i.imgur.com/gif1.gif",
      "thumbnail_url" => "http://i.imgur.com/gif1b.gif"
    }])
  end

  get("/api/gifs/gif2") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, {
      "id" => "gif2",
      "url" => "http://i.imgur.com/gif2.gif",
      "thumbnail_url" => "http://i.imgur.com/gif2b.gif"
    })
  end

  get("/api/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [])
  end

  post("/api/gifs/gif1/tags", { tag: "Shared Tag" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "shared-tag",
      "text" => "shared tag"
    })
  end

  post("/api/gifs/gif1/tags", { tag: "Custom Tag 1" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    })
  end

  post("/api/gifs/gif2/tags", { tag: "Shared Tag" }) do |json, status|
    assert_eql(status, 201)
    assert_eql(json, {
      "id" => "shared-tag",
      "text" => "shared tag"
    })
  end

  post("/api/gifs/gif2/tags", { tag: "Custom Tag 2" }) do |json, status|
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

  get("/api/gifs/gif1/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    }, {
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/gifs/gif2/tags") do |json, status|
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

  delete("/api/gifs/gif1/tags/custom-tag-1") do |json, status|
    assert_eql(status, 202)
    assert_eql(json, {
      "id" => "custom-tag-1",
      "text" => "custom tag 1"
    })
  end

  get("/api/gifs/gif1/tags") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "shared-tag",
      "text" => "shared tag"
    }])
  end

  get("/api/gifs?q=shared") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "gif2",
      "url" => "http://i.imgur.com/gif2.gif",
      "thumbnail_url" => "http://i.imgur.com/gif2b.gif"
    }, {
      "id" => "gif1",
      "url" => "http://i.imgur.com/gif1.gif",
      "thumbnail_url" => "http://i.imgur.com/gif1b.gif"
    }])
  end

  get("/api/gifs?q=custom") do |json, status|
    assert_eql(status, 200)
    assert_eql(json, [{
      "id" => "gif2",
      "url" => "http://i.imgur.com/gif2.gif",
      "thumbnail_url" => "http://i.imgur.com/gif2b.gif"
    }])
  end
end


