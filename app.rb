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
require 'chartkick'
require 'groupdate'
%w( dm-core dm-timestamps dm-types restclient xmlsimple).each  { |lib| require lib}

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier_google'], config['secret_goole']
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
    @list = Shortenedurl.all(:order => [ :id.desc ], :limit => 20)
    # in SQL => SELECT * FROM "Shortenedurl" ORDER BY "id" ASC
    haml :index
  else
    redirect '/session'
  end
end

get '/visitado' do
    puts "inside get '/': #{params}"
    @list = Shortenedurl.visits.all()
    puts @list
    puts "-------------------------------------------"
    # in SQL => SELECT * FROM "Shortenedurl" ORDER BY "id" ASC
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
  @list = Shortenedurl.all(:uid => session[:uid])
  haml :user
end

get '/session' do
  @list = Shortenedurl.all(:uid => session[:uid])
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
#  Shortenedurl.all.destroy
#  redirect '/'
#end

post '/' do
  puts "inside post '/': #{params}"
  uri = URI::parse(params[:url])
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
      sh = (params[:urlshort] != '') ? params[:urlshort] : (Shortenedurl.count+1)
      @short_url = Shortenedurl.first_or_create(:uid => session[:uid], :email => session[:email], :url => params[:url], :urlshort => sh, :n_visits => 0)
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
  short_url = Shortenedurl.first(:urlshort => params[:shortened])
  short_url.n_visits += 1
  ip = get_remote_ip(env)
  address = get_country(ip)
  visit = Visit.new(:created_at => Time.now, :ip => ip, :country => address, :shortenedurl => short_url)
  visit.save!
  # HTTP status codes that start with 3 (such as 301, 302) tell the
  # browser to go look for that resource in another location. This is
  # used in the case where a web page has moved to another location or
  # is no longer at the original location. The two most commonly used
  # redirection status codes are 301 Move Permanently and 302 Found.
  redirect short_url.url, 301
end

#error do haml :index end

def get_remote_ip(env)
  puts "request.url = #{request.url}"
  puts "request.ip = #{request.ip}"
  if addr = env['HTTP_X_FORWARDED_FOR']
    puts "env['HTTP_X_FORWARDED_FOR'] = #{addr}"
    addr.split(',').first.strip
  else
    puts "env['REMOTE_ADDR'] = #{env['REMOTE_ADDR']}"
    env['REMOTE_ADDR']
  end
end

def get_ip
  (RestClient.get "http://whatismyip.akamai.com").to_s
end

def get_country(ip)
  xml = RestClient.get "http://api.hostip.info/get_xml.php?ip=#{ip}"  
  XmlSimple.xml_in(xml.to_s)['featureMember'][0]['Hostip'][0]['countryName'][0]
end

['/info/:short_url', '/info/:short_url/:num_of_days', '/info/:short_url/:num_of_days/:map'].each do |path|
  get path do
    @link = Shortenedurl.first(:urlshort => params[:short_url])
    @visit = Visit.all()
    @country = Hash.new
    @visit.count_by_country_with(params[:short_url]).to_a.each do |item|
      @country[item.country] = item.count
    end
    @days = Hash.new
    @visit.as_date(params[:short_url]).each do |item|
      @days[item.date] = item.count
    end
    #@num_of_days = (params[:num_of_days] || 15).to_i
    #@count_days_bar = Visit.count_days_bar(params[:short_url], @num_of_days)
    #chart = Visit.count_country_chart(params[:short_url], params[:map] || 'world')
    #@count_country_map = chart[:map]
    #@count_country_bar = chart[:bar]
    haml :info, :layout => :admin
  end
end
