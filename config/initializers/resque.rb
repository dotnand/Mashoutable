require 'resque'
require 'resque/server'

uri           = URI.parse(ENV["REDIS_URL"])
Resque.redis  = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

