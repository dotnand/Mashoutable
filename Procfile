web:        bundle exec thin start -p $PORT -R config.ru -e $RACK_ENV
worker:     bundle exec rake resque:work QUEUE='*' INTERVAL=0.1 
scheduler:  bundle exec rake resque:scheduler 
