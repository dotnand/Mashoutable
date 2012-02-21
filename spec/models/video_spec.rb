require 'spec_helper'

describe Video do
  it { should belong_to(:user) }
  it { should validate_presence_of(:guid) }
  it { should validate_presence_of(:user) }
end
