require 'spec_helper'

describe Message do
  let(:message) { Message.new }
  
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }
  it { should validate_format_of(:email).with('12345').with_message(/email is invalid/) }
  
  it 'should not persist' do
    message.persisted?.should be_false
  end
end
