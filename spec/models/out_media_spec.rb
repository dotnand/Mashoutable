require 'spec_helper'

describe OutMedia do
  it { should belong_to(:out) }
  it { should validate_presence_of(:out) }
  it { should validate_presence_of(:media) }
end

