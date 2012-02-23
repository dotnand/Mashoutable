shared_context 'user videos' do
  let(:videos_paginated) { [double(:guid => '123'), double(:guid => '456'), double(:guid => '567')] }
  let(:videos) { double(:paginate => videos_paginated) }
end
