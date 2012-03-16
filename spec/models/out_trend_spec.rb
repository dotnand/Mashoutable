require 'spec_helper'

describe OutTrend do
  it { should belong_to :out }
  it { should validate_presence_of :out }
  it { should validate_presence_of :trend }
end
