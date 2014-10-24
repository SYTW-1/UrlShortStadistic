ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require 'bundler/setup'
require 'sinatra'
require 'data_mapper'
require_relative '../app.rb'

describe "shortened urls" do

	before :all do
		@user = "0000"
		@url = "http://www.google.es"
		@urlshort = "google"
		@short_url = ShortenedUrl.first_or_create(:uid => @user, :url => @url, :urlshort => @urlshort)
		@short_url1 = ShortenedUrl.first(:urlshort => @urlshort)
	end

	it "Se comprueba que la entrada esta en la base de datos" do
		assert @urlshort, @short_url1.urlshort
	end

	it "La url larga coincide" do
		assert @url, @short_url1.url
	end

	it "El usuario de la consulta es 0000" do
		assert '0000', @short_url1.uid
	end

end