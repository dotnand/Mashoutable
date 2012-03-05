shared_context 'grouped augmented interactions' do
  let(:grouped_augmented_interaction1) { {:screen_name => twitter_profile1.screen_name, :profile_image_url => twitter_profile1.profile_image_url, :count => 3} }
  let(:grouped_augmented_interaction2) { {:screen_name => twitter_profile2.screen_name, :profile_image_url => twitter_profile2.profile_image_url, :count => 2} }
  
  let(:grouped_augmented_interactions) { [grouped_augmented_interaction1.stringify_keys, grouped_augmented_interaction2.stringify_keys] }
end
