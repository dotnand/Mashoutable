class ReportMailer < ActionMailer::Base
  default :from => "reports@mashoutable.com"

  def report_email(reports)
    @reports = reports

    unless @reports.is_a?(Array)
      @reports = [@reports]
    end

    @reports.each do |report|
      if report[:filename]
        attachments[report[:filename]] = report[:table].to_csv
      end
    end
    mail(:to => 'user@example.com', :subject => "Report for #{Date.yesterday}")
  end
end

