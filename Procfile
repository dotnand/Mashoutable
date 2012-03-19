web:    bundle exec thin start -p $PORT -R config.ru
worker: bundle exec rake resque:work QUEUE='*' INTERVAL=0.1 
