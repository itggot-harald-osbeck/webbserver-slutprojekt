require_relative 'handler.rb'
# require 'Dbhandler'

class Thread < Handler
    table("threads")
    
    def intialize(title, text, user_id, tags)
        @title = title
        @text = text
        @user_id = user_id
        @tags = tags
    end
    
    def self.new(title, text, user_id, tags)
        @db.execute('INSERT INTO threads(title, text, user_id)
        VALUES (?,?,?)', title, text, user_id)

        @db.transaction()
        @thread_id = @db.execute('SELECT threads.id
        FROM threads
        ORDER BY id DESC
        LIMIT 1').first['id']
        @db.commit()

        tags.each do |tag|
            p tag
            p @thread_id
            @db.execute('INSERT INTO taggings(tag_id, thread_id)
            VALUES (?,?)', tag, @thread_id)
        end        

        return @thread_id
    end
end