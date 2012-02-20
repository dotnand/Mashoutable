shared_context 'twitter besties' do
  let(:local_bestie1) { double(:screen_name => '@twitter_1') }
  let(:local_bestie2) { double(:screen_name => '@twitter_2') }
  let(:local_bestie3) { double(:screen_name => '@twitter_3') }

  let(:twitter_bestie1) { double(:profile_image_url => 'http://www.foobar.com', :screen_name => '@twitter_1', :description => 'twitter_1 desc.', :location => 'San Fransico') }
  let(:twitter_bestie2) { double(:profile_image_url => 'http://www.helloworld.com', :screen_name => '@twitter_2', :description => 'twitter_2 desc.', :location => 'New York') }
  let(:twitter_bestie3) { double(:profile_image_url => 'http://www.twitterland.com', :screen_name => '@twitter_3', :description => 'twitter_3 desc.', :location => 'Las Vagas') }
  
  let(:twitter_besties) { [twitter_bestie1, twitter_bestie1, twitter_bestie3] }
end
