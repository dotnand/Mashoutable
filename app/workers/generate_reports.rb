class GenerateReports
  @queue = :generate_reports_queue

  def self.out_count(user_ids = [])
    blastouts = Blastout.where(:user_id => user_ids)
    mashouts  = Mashout.where(:user_id => user_ids)
    shoutouts = Shoutout.where(:user_id => user_ids)

    [blastouts.count, mashouts.count, shoutouts.count]
  end

  def self.build_provider_report_row(provider, user_ids)
    blastout_count, mashout_count, shoutout_count = out_count(user_ids)
    { 'Provider' => provider,
      'User Count' => user_ids.count,
      'Blastouts' => blastout_count,
      'Mashouts' => mashout_count,
      'Shoutouts' => shoutout_count
    }
  end

  def self.build_out_count_row(status, all, blastouts, mashouts, shoutouts)
    { 'Status' => status,
      'All' => all.count,
      'Blastouts' => blastouts.count,
      'Mashouts' => mashouts.count,
      'Shoutouts' => shoutouts.count
    }
  end

  def self.build_out_counts_report
    table             = Table(%w(Status All Blastouts Mashouts Shoutouts))
    outs              = Out.all

    successful_outs      = Out.where(:error => nil)
    successful_blastouts = successful_outs.where(:type => Blastout)
    successful_mashouts  = successful_outs.where(:type => Mashout)
    successful_shoutouts = successful_outs.where(:type => Shoutout)

    table << build_out_count_row('Success',
                                 successful_outs,
                                 successful_blastouts,
                                 successful_mashouts,
                                 successful_shoutouts)

    unsuccessful_outs = Out.where("error IS NOT NULL")
    unsuccessful_blastouts = unsuccessful_outs.where(:type => Blastout)
    unsuccessful_mashouts = unsuccessful_outs.where(:type => Mashout)
    unsuccessful_shoutouts = unsuccessful_outs.where(:type => Shoutout)

    table << build_out_count_row('Unsuccessful',
                                 unsuccessful_outs,
                                 unsuccessful_blastouts,
                                 unsuccessful_mashouts,
                                 unsuccessful_shoutouts)

    table << { 'Status' => 'Total',
               'All' => table.sum('All'),
               'Blastouts' => table.sum('Blastouts'),
               'Mashouts' => table.sum('Mashouts'),
               'Shoutouts' => table.sum('Shoutouts') }

     table
  end

  def self.build_providers_report
    table                      = Table(['Provider', 'User Count', 'Blastouts', 'Mashouts', 'Shoutouts'])
    users_with_authorizations  = User.joins(:authorizations)
    providers                  = [Authorization::FACEBOOK,
                                  Authorization::TWITTER,
                                  [Authorization::FACEBOOK,
                                   Authorization::TWITTER]]

    providers.each do |provider|
      if provider.is_a?(String)
        # Users that authorized this provider
        users         = users_with_authorizations.where(:authorizations => { :provider => provider })
        user_ids      = users.map(&:id)
        provider_name = provider.titleize

        table << build_provider_report_row(provider_name, user_ids)

        users = users.select { |user| user.authorizations.count == 1 }
        user_ids = users.map(&:id)
        provider_name = provider_name + ' Only'

        table << build_provider_report_row(provider_name, user_ids)
      else
        users = []
        # Get the users for each provider
        provider.each do |individual_provider|
          users << users_with_authorizations.where(:authorizations => { :provider => individual_provider })
        end
        # Intersect the users from each provider to get the users that
        # have authorized with all providers in the list
        users         = users.inject(:&)
        user_ids      = users.map(&:id)
        provider_name = provider.map(&:titleize).join(' / ')

        table << build_provider_report_row(provider_name, user_ids)
      end
    end

    table
  end

  def self.build_errors_report
    table        = Table(%w(Error Count Percent))
    error_counts = Out.count(:all, :group => :error).select { |error, count| error != nil }
    error_counts = error_counts.sort_by { |error, count| count }.reverse

    error_counts.each do |error, count|
      table << { 'Error' => error,
                 'Count' => count,
                 'Percent' => '%.2f%' % ((count.to_f / error_counts.map { |error, count| count }.inject(:+).to_f)*100) }
    end

    table
  end

  def self.perform
    reports = []

    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_providers_report.csv",
                 :name => 'Provider Statistics',
                 :table => build_providers_report }
=begin
    # TODO: Error reporting after errors on Outs is implemented as a has_many
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_out_counts_report.csv",
                 :name => 'Out Statistics',
                 :table => build_out_counts_report }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_errors_report.csv",
                 :name => 'Error Statistics',
                 :table => build_errors_report }
=end

    ReportMailer.report_email(reports).deliver
  end
end

