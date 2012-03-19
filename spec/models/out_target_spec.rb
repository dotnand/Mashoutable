require 'spec_helper'

describe OutTarget do
  it { should belong_to :out }
  it { should validate_presence_of :out }
  it { should validate_presence_of :target }
end
