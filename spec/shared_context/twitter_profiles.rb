shared_context 'twitter profiles' do
  let(:twitter_profile1) { double(:id => 1, :profile_image_url => 'http://www.foobar.com', :screen_name => '@twitter_1', :description => 'twitter_1 desc.', :location => 'San Fransico') }
  let(:twitter_profile2) { double(:id => 2, :profile_image_url => 'http://www.helloworld.com', :screen_name => '@twitter_2', :description => 'twitter_2 desc.', :location => 'New York') }
  let(:twitter_profile3) { double(:id => 3, :profile_image_url => 'http://www.twitterland.com', :screen_name => '@twitter_3', :description => 'twitter_3 desc.', :location => 'Las Vagas') }
  let(:twitter_profile4) { double(:id => 4, :profile_image_url => 'http://www.hellobar.com', :screen_name => '@twitter_4', :description => 'twitter_4 desc.', :location => 'Seattle') }
  let(:twitter_profile5) { double(:id => 5, :profile_image_url => 'http://www.fooworld.com', :screen_name => '@twitter_5', :description => 'twitter_5 desc.', :location => 'Washington') }
end
