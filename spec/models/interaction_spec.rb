require 'spec_helper'

describe Interaction do
  it { should belong_to(:user) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:target) }
end
