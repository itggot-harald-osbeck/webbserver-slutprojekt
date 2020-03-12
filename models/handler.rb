require_relative '../app.rb'
# require_relative 'thread.rb'

class Handler

    # attr_reader :text

    def self.db
        db = SQLite3::Database.new('C:\Users\harald.osbeck\Documents\GitHub\webbserver-slutprojekt\db\tillbakablick.db')
        db.results_as_hash = true
        return db
    end

    # def self.table(name)
    #     @table_name = name
    # end

    # def self.get(selection, join_statement="", where_statement="", input[])
    #     db.execute("SELECT #{selection} FROM #{@table_name} WHERE ")
    # end

end

class Bthread < Handler
    # table("threads")
    
    attr_reader :title, :text, :thread_id, :user_id, :tags
    
    def initialize(title, text, thread_id, user_id, tags)
        @title = title
        @text = text
        @thread_id = thread_id.to_i
        @user_id = user_id.to_i
        @tags = tags

    end
    
    def self.get_all()
        threads = db.execute('SELECT threads.*, users.name as user
        FROM threads
        JOIN users
        ON threads.user_id = users.id')

        threads_data = db.execute('SELECT threads.*, users.name as user, tags.id as tag_id, tags.name as tag_name
        FROM threads
        JOIN users
        ON threads.user_id = users.id
        JOIN tags
        JOIN taggings
        ON tags.id = taggings.tag_id AND taggings.thread_id = threads.id')
                
        
        # symthreads = []
        # threads.each do |thread|
        #     new_thread = {}
        #     thread.each do |key, value|
        #         new_thread[key.to_sym] = value
        #     end
        #     symthreads << new_thread
        # end

        objectthreads = []
        thread_tags = []
        p_id = 1
        threads.each do |thread|
            if p_id == thread['id']
                thread_tags << thread['tag_id']
            else 
                objectthreads << Bthread.new(thread['title'],thread['text'],thread['id'],thread['user_id'], thread_tags)
                p_id = thread['id']
                thread_tags = []
                thread_tags << thread['tag_id']
            end 
        end

        # return symthreads
        return objectthreads
    end

    def insert(title, text, user_id, tags)
        Handler.db.execute('INSERT INTO threads(title, text, user_id)
        VALUES (?,?,?)', @title, @text, @user_id)

        thread_id = Handler.db.execute('SELECT threads.id
        FROM threads
        ORDER BY id DESC
        LIMIT 1').first['id']

        tags.each do |tag|
            Handler.db.execute('INSERT INTO taggings(tag_id, thread_id)
            VALUES (?,?)', tag, thread_id)
        end
        return thread_id
    end

end

class Comment < Handler 
    def initialize(text, user_id, thread_id)
    
    end
        
    def self.get_all
        comments = db.execute('SELECT comments.* 
        FROM comments')
        return comments
    end

    def find(thread_id)
        threadcomments = db.execute("SELECT comments.* 
        FROM comments
        WHERE thread_id = #{thread_id}")
        symcomments = [] 
        threadcomments.each do |comment|
            if comment['comment_text']
                symcomments << {user: comment['commenter_name'], text: comment['comment_text']}
            end
        end

        return symcomments
    end
end