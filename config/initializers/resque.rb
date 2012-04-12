require 'resque'
require 'resque/server'
require 'resque_scheduler'

uri             = URI.parse(ENV["REDIS_URL"])
Resque.redis    = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

