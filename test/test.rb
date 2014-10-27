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
  		@visit = Visit.new(:ip => @ip, :country => @country, :countryCode => @countryCode, :city => @city, :latitude => @latitude, :longitude => @longitude, :shortenedurl => @short_url1, :created_at => Time.now)
  		@visit.save
	end

	it "El usuario de la consulta es 0000" do
		assert_equal '0000', @short_url1.uid
	end

	it "El email de la consulta es test@email.es" do
		assert_equal @email, @short_url1.email
	end

	it "Se comprueba que la entrada esta en la base de datos" do
		assert_equal @urlshort, @short_url1.urlshort
	end

	it "La url larga coincide" do
		assert @url, @short_url1.url
	end

	it "El numero de visitas es 1" do
		assert_equal 0, @short_url1.n_visits
	end

	it "La ip es 88.10.68.232" do
		assert_equal @ip, @visit.ip.to_s
	end

	it "La ciudad es SPAIN" do
		assert_equal @country, @visit.country
	end

	it "El codigo de ciudad es SP" do
		assert_equal @countryCode, @visit.countryCode
	end

	it "La ciudad es santa cruz" do
		assert_equal @city, @visit.city
	end

	it "La latitud es 0000" do
		assert_equal @latitude, @visit.latitude
	end

	it "La longitud es 1111" do
		assert_equal @longitude, @visit.longitude
	end

	it "La longitud es 1111" do
		assert_equal @longitude, @visit.longitude
	end

	it "La url corta coincide" do
		assert_equal @urlshort, @visit.shortenedurl.urlshort
	end
	
end