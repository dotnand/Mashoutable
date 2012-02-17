TWITTER_CONFIG  = YAML.load_file("#{Rails.root}/config/twitter.yml")[Rails.env]
FACEBOOK_CONFIG = YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_CONFIG['CONSUMER_KEY'], TWITTER_CONFIG['CONSUMER_SECRET']
  provider :facebook, FACEBOOK_CONFIG['APP_ID'], FACEBOOK_CONFIG['APP_SECRET'], :scope => 'email,offline_access,read_stream'
end

OmniAuth.config.full_host = 'http://localhost:3000'

  Twitter.configure do |config|
  config.consumer_key = TWITTER_CONFIG['CONSUMER_KEY']
  config.consumer_secret = TWITTER_CONFIG['CONSUMER_SECRET']
end

