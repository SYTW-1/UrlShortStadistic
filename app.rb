#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'uri'
require 'pp'
require 'data_mapper'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'omniauth-github'
require 'omniauth-facebook'

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier_google'], config['secret_google']
  provider :github, config['identifier_github'], config['secret_github']
  provider :facebook, config['identifier_facebook'], config['secret_facebook']
end

enable :sessions
set :session_secret, '*&(^#234a)'

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

configure :test do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
end

DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize

#DataMapper.auto_migrate!
DataMapper.auto_upgrade!

Base = 36

get '/index' do
  haml :index
end

get '/' do
  if !session[:uid]
    puts "inside get '/': #{params}"
    @list = ShortenedUrl.all(:order => [ :id.desc ], :limit => 20)
    # in SQL => SELECT * FROM "ShortenedUrl" ORDER BY "id" ASC
    haml :index
  else
    redirect '/session'
  end
end

get '/auth/:name/callback' do
  @auth = request.env['omniauth.auth']
  session[:plt] = (params[:name] == 'google_oauth2') ? 'google' : params[:name]
  session[:uid] = @auth['uid'];
  if params[:name] == 'google_oauth2' || params[:name] == 'facebook'
    session[:name] = @auth['info'].first_name + " " + @auth['info'].last_name
    session[:email] = @auth['info'].email
  elsif params[:name] == 'github' 
    session[:name] = @auth['info'].nickname
    session[:email] = @auth['info'].email
  end
  @list = ShortenedUrl.all(:uid => session[:uid])
  haml :user
end

get '/session' do
  @list = ShortenedUrl.all(:uid => session[:uid])
  haml :user
end

get '/logout' do
  session.clear
  #redirect 'https://www.google.com/accounts/Logout?continue=https://appengine.google.com/_ah/logout?continue=' + to('/')
  redirect '/'
end

get '/stadistic' do
  haml :stadistic, :layout => :admin
end

#get '/delete' do
#  ShortenedUrl.all.destroy
#  redirect '/'
#end

post '/' do
  puts "inside post '/': #{params}"
  uri = URI::parse(params[:url])
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
      sh = (params[:urlshort] != '') ? params[:urlshort] : (ShortenedUrl.count+1)
      @short_url = ShortenedUrl.first_or_create(:uid => session[:uid], :email => session[:email], :url => params[:url], :urlshort => sh)
    rescue Exception => e
      puts "EXCEPTION!!!!!!!!!!!!!!!!!!!"
      pp @short_url
      puts e.message
    end
  else
    logger.info "Error! <#{params[:url]}> is not a valid URL"
  end
  if !session[:uid]
    redirect '/'
  else
    redirect 'session'
  end
end

get '/:shortened' do
  puts "inside get '/:shortened': #{params}"
  short_url = ShortenedUrl.first(:urlshort => params[:shortened])

  # HTTP status codes that start with 3 (such as 301, 302) tell the
  # browser to go look for that resource in another location. This is
  # used in the case where a web page has moved to another location or
  # is no longer at the original location. The two most commonly used
  # redirection status codes are 301 Move Permanently and 302 Found.
  redirect short_url.url, 301
end

error do haml :index end
