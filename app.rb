require_relative "models/handler.rb"

class App < Sinatra::Base

    enable :sessions
	
	before do 
		@db = SQLite3::Database.new('db/tillbakablick.db')
		@db.results_as_hash = true
		if session[:user_id]
			@username = session[:name]
            @userid = session[:user_id]
            @role = session[:role]
        end
    end
    
    get '/' do
        redirect "/login/"
    end
    
    get '/login/?' do
        slim :'user/login'
    end

    get  '/user/new/?' do
        slim :'user/new'
    end

    get '/threads/?' do
        #@threads = Thread.get
        # threads = @db.execute('SELECT threads.*, users.name as user
        #     FROM threads
        #     JOIN users
        #     ON threads.user_id = users.id')
        # @threads = []
        # threads.each do |thread|
        #     new_thread = {}
        #     thread.each do |key, value|
        #         new_thread[key.to_sym] = value
        #     end
        #     @threads << new_thread
        # end
        @threads = Bthread.get_all()

        slim :'threads/index'
    end
    
    get '/threads/new/?' do
        tags = @db.execute('SELECT tags.*
            FROM tags')
        @tags = []
        tags.each do |tag|
            new_tag = {}
            tag.each do |key, value|
                new_tag[key.to_sym] = value
            end
            @tags << new_tag
        end

        slim :'threads/new'
    end
    
    get '/threads/:id/?' do

        # @thread_data = @db.execute('SELECT threads.*, users.name, commenters.name as commenter_name, comments.text as comment_text, comments.id as comment_id
        # FROM threads
        # LEFT JOIN users
        # ON threads.user_id = users.id
        # JOIN users as commenters
        # LEFT JOIN comments 
        # ON comments.thread_id = threads.id AND comments.user_id = commenters.id
        # WHERE threads.id = ?', params['id'])
    
        # @thread = {text: @thread_data[0]['text'], title: @thread_data[0]['title'], user: @thread_data[0]['name'] }
        
        # @comments = []
        # @thread_data.each do |comment|
        #     if comment['comment_text']
        #         @comments << {user: comment['commenter_name'], text: comment['comment_text']}
        #     end
        # end
    
        threads = Bthread.get_all
        @thread = threads.find { |t| t.thread_id == params['id'].to_i }
        p threads
        p "#############"
        p @thread
        p "#############"

        allcomments = Comment.get_all
        @comments = allcomments.find(params['id'])

        slim :'threads/show'
    end


    get '/threads/tag/:tagid/?' do

        threads = @db.execute('SELECT threads.*, users.name as user, taggings.*, tags.name as tag_name
        FROM threads
        JOIN users
        ON threads.user_id = users.id
        JOIN taggings
        ON threads.id = taggings.thread_id
        JOIN tags
        ON tags.id = taggings.tag_id
        WHERE taggings.tag_id = ?', params['tagid'])
        @threads = []
        threads.each do |thread|
            new_thread = {}
            thread.each do |key, value|
                new_thread[key.to_sym] = value
            end
            @threads << new_thread
        end

        slim :'threads/tagthreads'
    end

    get '/user/:userid/?' do
        
        @user_data = @db.execute('SELECT users.name, users.role , threads.id as thread_id, threads.title as thread_title, threads.text as thread_text, comments.id as comment_id, comments.text as comment_text
        FROM users
        LEFT JOIN threads
        ON threads.user_id = users.id
        LEFT JOIN comments
        ON comments.user_id = users.id
        WHERE users.id = ?', params['userid'])

        @check = 0
        @user_threads = []
        @user_data.each do |thread|
            if @check != thread['thread_id']
                @user_threads << {text: thread['thread_text'], title: thread['thread_title'], user: thread['name'] }
                @check = thread['thread_id']
            end
        end
        @check2 = 0
        @user_comments = []
        @user_data.each do |comment|
            if @check2 != comment['comment_id']
                @user_comments << {text: comment['comment_text'], id: comment['comment_id'], user: comment['name'] }
                @check2 = comment['comment_id']
            end
        end
        #@username = User.name ??
        @username = @user_data[0]['name']

        slim :'user/index'
    end

    post '/login' do
        username = params['name']
        userdata = @db.execute('SELECT name, id, pwd_hash, role FROM users WHERE name = ?', username).first
        password = BCrypt::Password.new(userdata['pwd_hash'])
        
        
        if password == params['plaintext']
			session[:user_id] = userdata['id']
            session[:role] = userdata['role']
            session[:name] = userdata['name']
			redirect "/threads"
		else
			redirect '/login'
		end
        
    end

    post '/user/new/?' do
        username = params['name']
        if @db.execute('SELECT name FROM users WHERE name = ?', username) == []
            pwd_hash = BCrypt::Password.create(params['plaintext'])
            @db.execute('INSERT INTO users(name, pwd_hash, role) VALUES (?,?,?)', username, pwd_hash, 0)
            
            userdata = @db.execute('SELECT name, id, pwd_hash, role FROM users WHERE name = ?', username).first
            session[:user_id] = userdata['id']
            session[:role] = userdata['role']
            session[:name] = userdata['name']

            redirect '/threads'
        
        end
    end

    post '/threads/new/?' do
        # thread_id = Bthread.new(params['title'], params['text'], session[:user_id], params['tag_ids'])
        thread = Bthread.new(params['title'], null, params['text'], session[:user_id], params['tag_ids'])
        thread_id = thread.insert(params['title'], params['text'], session[:user_id], params['tag_ids'])
        
        redirect "/threads/#{thread_id}"
    end

    post '/threads/:id/?' do
        if params['text'].length > 0
            @db.execute('INSERT INTO comments(thread_id, text, user_id)
            VALUES (?,?,?)', params['id'], params['text'], session[:user_id])
        end
        redirect "threads/#{params['id']}"
    end


end