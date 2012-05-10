require 'spec_helper'

describe OutRetweetTarget do
  it { should belong_to(:out) }
  [:out, :status_id, :target].each do |required|
    it { should validate_presence_of(required) }
  end
end

