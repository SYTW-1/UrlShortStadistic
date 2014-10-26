require 'dm-core'
require 'dm-migrations'
require 'restclient'
require 'xmlsimple'

class Shortenedurl
  include DataMapper::Resource

  property :id, Serial
  property :uid, String
  property :email, String
  property :url, Text
  property :urlshort, Text

  has n, :visits
end

class Visit
  include DataMapper::Resource

  property  :id,          Serial
  property  :created_at,  DateTime
  property  :ip,          IPAddress
  property  :country,     String
  belongs_to  :shortenedurl
end