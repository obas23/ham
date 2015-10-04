require 'json'

require_relative "ham/version"
require_relative "ham/errors"
require_relative "ham/db"
require_relative "ham/gif"
require_relative "ham/tag"
require_relative "ham/web/app"
require_relative "ham/web/api"

module Ham
  def self.root
    File.expand_path(File.join(File.dirname(__FILE__), "/../"))
  end

  def self.config
    @config ||= OpenStruct.new({
      db: File.join(root, "db", "ham.db")
    })
  end

  def self.configure(*args, &block)
    yield config if block_given?
  end

  def self.db
    @db ||= DB.new(config.db)
  end
end

