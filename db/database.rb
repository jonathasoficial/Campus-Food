require "sqlite3"

class Database 
  def self.connection
    @connection ||= SQLite3::Database.new("db/cantina.db").tap do |db|
      db.results_as_hash = true
    end
  end
end