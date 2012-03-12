require 'spec_helper'

describe Authorization do
  let!(:user) { FactoryGirl.create(:authorization) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }
  
  describe 'returns an authorization given a hash' do
    let(:param) { {'provider' => 'provider a', 'uid' => 'uid a', 'credentials' => {'secret' => 'secret a', 'token' => 'token 1'}} }
    let(:user)  { FactoryGirl.build(:user) }
  
    it 'should find authorization from given a hash' do
      Authorization.should_receive('find_by_provider_and_uid')
                   .with(param['provider'], param['uid'])
      Authorization.find_from_hash(param)
    end
    
    it 'should create an authorization given a hash and no user' do
      User.should_receive('create_from_hash!').and_return(user)
      Authorization.should_receive('create')
                   .with(:user => user, :uid => param['uid'], :provider => param['provider'], :secret => 'secret a', :token => 'token 1')
      Authorization.create_from_hash(param)          
    end
    
    it 'should create an authorization given a hash and a user' do
      Authorization.should_receive('create')
                   .with(:user => user, :uid => param['uid'], :provider => param['provider'], :secret => 'secret a', :token => 'token 1')
      Authorization.create_from_hash(param, user)          
    end
  end
end
