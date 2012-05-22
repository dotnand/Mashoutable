require "spec_helper"

describe ReportMailer do
  describe 'report_email' do
    before do
      @user = FactoryGirl.create(:user)
      @user.authorizations << FactoryGirl.create(:authorization, :provider => 'twitter')
      @user.outs << FactoryGirl.create(:out)
      @report = ProvidersReport.new
    end

    it 'should render successfully' do
      lambda { ReportMailer.report_email(@report) }.should_not raise_error
    end
  end
end

