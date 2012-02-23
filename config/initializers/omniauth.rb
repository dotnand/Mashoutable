Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']
  provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], :scope => 'email,offline_access,read_stream'
end

OmniAuth.config.full_host = 'http://localhost:3000' if not Rails.env.production?

Twitter.configure do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
end

