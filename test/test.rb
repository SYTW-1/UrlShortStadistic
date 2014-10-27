ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require_relative '../app'

describe "shortened urls" do

	before :all do
		@user = "0000"
		@email = "test@email.es"
		@url = "http://www.google.es"
		@urlshort = "google"
		@ip = "88.10.68.232"
		@country = "SPAIN"
		@countryCode = "SP"
		@city = "santa cruz"
		@latitude = "0000"
		@longitude = "1111"

		@short_url = Shortenedurl.first_or_create(:uid => @user, :email => @email, :url => @url, :urlshort => @urlshort, :n_visits => 0)
		@short_url1 = Shortenedurl.first(:urlshort => @urlshort)

  		@short_url.n_visits += 1
  		@visit = Visit.new(:ip => @ip, :country => @country, :countryCode => @countryCode, :city => @city, :latitude => @latitude, :longitude => @longitude, :shortenedurl => @short_url1, :created_at => Time.now)
  		@visit.save!
	end

	it "El usuario de la consulta es 0000" do
		assert '0000', @short_url1.uid
	end

	it "El email de la consulta es test@email.es" do
		assert @email, @short_url1.email
	end

	it "Se comprueba que la entrada esta en la base de datos" do
		assert @urlshort, @short_url1.urlshort
	end

	it "La url larga coincide" do
		assert @url, @short_url1.url
	end

	it "El numero de visitas es 1" do
		assert 1, @short_url1.n_visits
	end

	
end