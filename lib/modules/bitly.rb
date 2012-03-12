module Bitly
  class Client
    include HTTParty
    
    base_uri 'https://api-ssl.bitly.com/'
    format :json
    
    def initialize(uri)
      @uri = uri
    end
    
    def shorten
      @response = Bitly::Client.get('/v3/shorten', :query => {:longUrl  => @uri,
                                                              :apiKey   => ENV['BITLY_API_KEY'],
                                                              :login    => ENV['BITLY_API_LOGIN']})
      @response['status_code'] == 200
    end
    
    def shortened_url
      return nil if @response.nil?
      @response['data']['url']
    end
  end
end
