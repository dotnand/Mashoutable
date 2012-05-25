shared_context 'capybara url options' do
  before(:all) do
  	[ApplicationController, ActionController::Base, DashboardController].each do |klass|
  	  klass.class_eval do
  	    def default_url_options(options = {})
  	      { :host => "127.0.0.1", :port => Capybara.server_port }.merge(options)
  	    end
  	  end
  	end
  end
end