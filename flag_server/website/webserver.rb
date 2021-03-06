require 'sinatra'
require 'slim'
require 'sqlite3'

# don't minify HTML
Slim::Engine.set_options pretty: true

configure do
  set :public_folder, 'public'
  set :views, 'views'
  set :bind, '0.0.0.0'
  set :port, 9999
  enable :sessions
  set :server, %w[thin webrick]
  set :environment, :production
  #set :environment, :development
  #disable :protection
  set :session_secret, '01344904559362f6f5754df256908476702c8bd5d972a32e2fae2a7cc6fa4a7efd25079fddb5a11a0f8be0f607bf048fd6ecfe065380c27b2aa26015c3308e85'
end

def authenticate!
  unless session[:username]
    redirect to('/login')
  end
end

### Create DB ###
# db = SQLite3::Database.new 'database.db'
# Create a table
# rows = db.execute <<-SQL
#   create table users (
#     username varchar(20),
#     password varchar(20),
#     role varchar(20)
#   );
# SQL
# Add admin account
# db.execute('INSERT INTO users (username, password, role) 
#             VALUES (?, ?, ?)', ['noraj', '6aa1439de6a17a517dc250a97929e4d8', 'admin'])
# db.close

get '/' do
  authenticate!
  redirect to('/home')
end

get '/login' do
  @message = params['message']
  @hide = 'hidden' if params['message'].nil?
  slim :login
end

post '/auth' do
  # Open a database
  db = SQLite3::Database.new 'database.db', {readonly: true}
  user = params['username']
  pass = params['password']
  query = "SELECT username, password, role FROM users WHERE username='#{user}' AND password='#{pass}';"
  rows = db.execute(query)
  db.close
  unless rows.empty?
    username, password, role = rows.first
    session.clear
    session[:username] = username
    session[:role] = role
    redirect to('/home')
  else
    sleep 0.1
    message = 'Wrong credentials!'
    redirect to("/login?message=#{message}") 
  end
end

post '/register' do
  # Open a database
  db = SQLite3::Database.new 'database.db'
  user = params['username']
  pass = params['password']
  # Check if user already exist
  query = "SELECT username FROM users WHERE username='#{user}';"
  rows = db.execute(query)
  unless rows.empty?
    sleep 0.1
    message = 'User already exists!'
    redirect to("/login?message=#{message}") 
  else
    # Create user
    rows = db.execute('INSERT INTO users (username, password, role) 
              VALUES (?, ?, ?)', [user.to_s, pass.to_s, 'user'])
  end
  db.close
  if rows.empty?
    sleep 0.1
    message = 'Registration successful!'
    redirect to("/login?message=#{message}") 
  else
    sleep 0.1
    message = 'Wrong credentials!'
    redirect to("/login?message=#{message}") 
  end
end

get '/home' do
  authenticate!
  @user = session[:username]
  @flag = ENV['FLAG'] if session[:role] == 'admin'
  slim :home
end

get '/logout' do
  session.clear
  message = 'You have been signed out.'
  redirect to("/login?message=#{message}") 
end

post '/id' do
  authenticate!
  unless params['message'].nil?
    id = params['message'].unpack('H*').first
    redirect to("/id/#{id}")
  else
    redirect to('/home') 
  end
end

get '/id/:id' do
  authenticate!
  @content = [params['id']].pack('H*')
  slim :id
end
