shared_context 'twitter besties' do
  let(:local_bestie1) { double(:screen_name => '@twitter_1') }
  let(:local_bestie2) { double(:screen_name => '@twitter_2') }
  let(:local_bestie3) { double(:screen_name => '@twitter_3') }

  let(:twitter_bestie1) { twitter_profile1 }
  let(:twitter_bestie2) { twitter_profile2 }
  let(:twitter_bestie3) { twitter_profile3 }

  let(:twitter_besties_paginated) { [twitter_bestie1, twitter_bestie1, twitter_bestie3] }  
  let(:twitter_besties) { double(:sort_by => double(:paginate => twitter_besties_paginated)) }
end
