require 'spec_helper'

describe Bitly::Client do
  let(:bitly) { Bitly::Client.new('http://foobar.com') }
  
  it 'should exist' do
    bitly.should_not be_nil
  end
  
  context 'shorten an url' do
    let(:response) { {'status_code' => 200} }
  
    before do
      Bitly::Client.should_receive(:get)
                   .with('/v3/shorten', :query => {:longUrl => 'http://foobar.com', :apiKey => ENV['BITLY_API_KEY'], :login => ENV['BITLY_API_LOGIN']})
                   .and_return(response)
    end
  
    it 'should be successful' do
      bitly.shorten.should be_true
    end  
    
    it 'should have a shortened url' do
      response['data'] = {'url' => 'http://shortened.com'}
      bitly.shorten.should be_true
      bitly.shortened_url.should eq(response['data']['url'])
    end
  end
end
