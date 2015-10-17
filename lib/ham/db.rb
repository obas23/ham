require 'pg'

module Ham
  class DB
    attr_reader :filename

    def initialize(filename)
      @filename = filename
      setup!
    end

    def db
      # @db ||= SQLite3::Database.new(filename)
      if (ENV['RACK_ENV'] == 'production')
        @db ||= PG.connect(:host => ENV['HOST'], :dbname => ENV['DB_NAME'], :user => ENV['db_user'], :password => ENV['db_password'])
      else 
        @db ||= PG.connect(:dbname => 'ham', :user => "Mike")
      end
    end

    def execute(*args, &block)
      db.exec(*args, &block)
    end

    def get_first_value(*args, &block)
      db.exec(*args, &block).values.flatten.first
    end

    def setup!
      # execute "create table if not exists gifs (id text unique, index integer primary key);"
      # execute "create table if not exists tags (id text unique, index integer primary key);"
      # execute "create table if not exists gifs_tags (gif_id text, tag_id text, index integer primary key);"
    end

    def reset!
      File.delete(filename) if File.exist?(filename)
      @db = nil
      setup!
    end

    def insert(table, id)
      begin
        db.exec("insert into #{table} (id) values ('#{id}')")
      rescue SQLite3::ConstraintException
      end
    end

    def ids(table)
      execute("select id from #{table} order by index desc").values.flatten
    end

    def find(table, id)
      get_first_value("select id from #{table} where id='#{id}'")
    end

    def count(table)
      get_first_value("select count(*) from #{table}")
    end

    def first(table)
      get_first_value("select id from #{table} order by index desc")
    end

    def last(table)
      get_first_value("select id from #{table} order by index asc")
    end

    def next(table, id)
      get_first_value("select id from #{table} where index < (select index from #{table} where id='#{id}') order by index desc")
    end

    def prev(table, id)
      get_first_value("select id from #{table} where index > (select index from #{table} where id='#{id}') order by index asc")
    end

    # Full search
    def search(table, query)
      execute("select id from #{table} where id like '%#{query}%'").values.flatten
    end

    # Autocomplete search
    def complete(table, query)
      execute("select id from #{table} where id like '#{query}%'").values.flatten
    end
  end
end

