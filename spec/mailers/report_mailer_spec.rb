require "spec_helper"

describe ReportMailer do
  describe 'report_email' do
    before do
      @user = FactoryGirl.create(:user)
      @user.authorizations << FactoryGirl.create(:authorization, :provider => 'twitter')
      @user.outs << FactoryGirl.create(:out)
      @report = {:filname => 'test_report.csv',
                 :name => 'Test Report',
                 :table => GenerateReports.build_providers_report }
    end

    it 'should render successfully' do
      lambda { ReportMailer.report_email(@report) }.should_not raise_error
    end
  end
end

