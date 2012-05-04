require 'spec_helper'

describe OutError do
  it { should validate_presence_of(:out) }
  it { should validate_presence_of(:source) }
  it { should validate_presence_of(:error) }
end

