require 'rspec/expectations'

RSpec::Matchers.define :match_json do |expected|
  match do |actual|
    JSON.parse(actual) == JSON.parse(expected.to_json)
  end

  failure_message do |actual|
    """
    expected #{JSON.parse(expected.to_json)}
      actual #{JSON.parse(actual)}
    """
  end
end

module Ham
  module TestHelpers

    def reset_db!
      Ham.db.reset!
    end

    def status
      last_response.status
    end

    def body
      last_response.body
    end
  end
end

