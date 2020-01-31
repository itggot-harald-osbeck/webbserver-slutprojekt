class Dbhandler

    def self.db
        db = SQLite3::Database.new('/db/tillbakablick.db')
        db.results_as_hash = true
        return db
    end

    def self.get
        
    end

end