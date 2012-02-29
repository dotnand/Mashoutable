module Bitly
  class Client
    include HTTParty
    
    base_uri 'https://api-ssl.bitly.com/'
    format :json
    
    def self.shorten(url)
      shortened = get('/v3/shorten', :query => {:longUrl  => url,
                                                :apiKey   => ENV['BITLY_API_KEY'],
                                                :login    => ENV['BITLY_API_LOGIN']})
    end
  end
end
