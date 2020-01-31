require 'sqlite3'
require 'bcrypt'

class Seeder
    
    def self.seed!
        db = connect
        drop_tables(db)
        create_tables(db)
        populate_tables(db)
        
    end
    
    def self.connect()
        db = SQLite3::Database.new "tillbakablick.db"
    end
    
    def self.drop_tables(db)
        db.execute('DROP TABLE IF EXISTS users;')
        db.execute('DROP TABLE IF EXISTS threads;')
        db.execute('DROP TABLE IF EXISTS tags;')
        db.execute('DROP TABLE IF EXISTS taggings;')
        db.execute('DROP TABLE IF EXISTS comments;')
    end
    
    
    def self.create_tables(db)
        db.execute <<-SQL
        CREATE TABLE "users" (
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "name"	TEXT NOT NULL UNIQUE,
            "pwd_hash"	TEXT NOT NULL,
            "role"	INTEGER NOT NULL
            );
            SQL
        db.execute <<-SQL
        CREATE TABLE "threads" (
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "title"	TEXT NOT NULL,
            "text"	TEXT NOT NULL,
            "user_id"	INTEGER NOT NULL
            );
            SQL
                    
        db.execute <<-SQL
        CREATE TABLE "tags" (
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "name"	INTEGER NOT NULL
            );
            SQL
                        
        db.execute <<-SQL
        CREATE TABLE "taggings" (
            "tag_id"	INTEGER NOT NULL,
            "thread_id"	INTEGER NOT NULL
            );
            SQL
        
        db.execute <<-SQL
        CREATE TABLE "comments" (
            "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
            "text"	INTEGER NOT NULL,
            "user_id"	INTEGER NOT NULL,
            "thread_id"	INTEGER NOT NULL
            );
            SQL
        
    end
    def self.populate_tables(db)
        users = [
            {name: "thememer", pwd_hash: BCrypt::Password.create("hejhej"), role: 2 },
            {name: "memerone", pwd_hash: BCrypt::Password.create("hejhej"), role: 1 },
            {name: "memertwo", pwd_hash: BCrypt::Password.create("hejhej"), role: 0 },
        ]
        users.each do |user|
            db.execute("INSERT INTO users (name, pwd_hash, role) VALUES(?,?,?)", user[:name], user[:pwd_hash], user[:role])
        end
        tags = [
            {name: "gaming"},
            {name: "general"},
            {name: "funny"},
        ]
        tags.each do |tag|
            db.execute("INSERT INTO tags (name) VALUES(?)", tag[:name])
        end        
        threads = [
            {title: "hi here's the first post by me, THE memer", text: "uhm yeah so it's the first thread, post, funny tefwjkf", user_id: 1 },
            {title: "hi thememer", text: "damn dude cool site, memerone was not available", user_id: 3 },
        ]
        threads.each do |thread|
            db.execute("INSERT INTO threads (title, text, user_id) VALUES(?,?,?)", thread[:title], thread[:text], thread[:user_id])
        end
        taggings = [
            {tag_id: 1, thread_id: 1 },
            {tag_id: 2, thread_id: 1 },
            {tag_id: 2, thread_id: 2 },
        ]
        taggings.each do |tags|
            db.execute("INSERT INTO taggings (tag_id, thread_id) VALUES(?,?)", tags[:tag_id], tags[:thread_id])
        end
        comments = [
            {text: "wow dude cool forum, this the first comment", user_id: 2, thread_id: 1 },
            {text: "it sure is, thanks i love my forum", user_id: 1, thread_id: 1 },
            {text: "why does no one else comment on my post", user_id: 3, thread_id: 2 },        
        ]
        comments.each do |comment|
            db.execute("INSERT INTO comments (text, user_id, thread_id) VALUES(?,?,?)", comment[:text], comment[:user_id], comment[:thread_id])
        end
    end
end

Seeder.seed!