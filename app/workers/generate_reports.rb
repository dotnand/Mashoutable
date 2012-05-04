class GenerateReports
  @queue = :generate_reports_queue

  def self.yesterday
    (Time.now.midnight - 1.day)..(Time.now.midnight)
  end

  def self.out_count(user_ids = [])
    blastouts = Blastout.created_yesterday.where(:user_id => user_ids)
    mashouts  = Mashout.created_yesterday.where(:user_id => user_ids)
    shoutouts = Shoutout.created_yesterday.where(:user_id => user_ids)

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
    table = Table(%w(Status All Blastouts Mashouts Shoutouts))

    outs      = Out.created_yesterday
    blastouts = outs.where(:type => Blastout)
    mashouts  = outs.where(:type => Mashout)
    shoutouts = outs.where(:type => Shoutout)

    successful_outs      = outs.select { |out| out.successful? }
    successful_blastouts = blastouts.select { |out| out.successful? }
    successful_mashouts  = mashouts.select { |out| out.successful? }
    successful_shoutouts = shoutouts.select { |out| out.successful? }

    table << build_out_count_row('Successful',
                                 successful_outs,
                                 successful_blastouts,
                                 successful_mashouts,
                                 successful_shoutouts)

    unsuccessful_outs      = outs - successful_outs
    unsuccessful_blastouts = blastouts - successful_blastouts
    unsuccessful_mashouts  = mashouts - successful_mashouts
    unsuccessful_shoutouts = shoutouts - successful_shoutouts

    table << build_out_count_row('Unsuccessful',
                                 unsuccessful_outs,
                                 unsuccessful_blastouts,
                                 unsuccessful_mashouts,
                                 unsuccessful_shoutouts)

    table << { 'Status'    => 'Total',
               'All'       => table.sum('All'),
               'Blastouts' => table.sum('Blastouts'),
               'Mashouts'  => table.sum('Mashouts'),
               'Shoutouts' => table.sum('Shoutouts') }

     table
  end

  def self.build_providers_report
    table                      = Table(['Provider', 'User Count', 'Blastouts', 'Mashouts', 'Shoutouts'])
    providers                  = [Authorization::FACEBOOK,
                                  Authorization::TWITTER,
                                  [Authorization::FACEBOOK,
                                   Authorization::TWITTER]]

    providers.each do |provider|
      if provider.is_a?(String)
        # Users that authorized this provider
        authorizations = Authorization.created_yesterday.where(:provider => provider)
        users          = authorizations.map(&:user)
        user_ids       = users.map(&:id)
        provider_name  = provider.titleize

        table << build_provider_report_row(provider_name, user_ids)

        users = users.select { |user| user.authorizations.count == 1 }
        user_ids = users.map(&:id)
        provider_name = provider_name + ' Only'

        table << build_provider_report_row(provider_name, user_ids)
      else
        users = []
        # Get the users for each provider
        provider.each do |individual_provider|
          authorizations = Authorization.created_yesterday.where(:provider => individual_provider)
          users << authorizations.map(&:user)
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
    table = Table(%w(Source Error Count Percent))
    error_sources = OutError.created_yesterday.count(:all, :group => :source)
    error_sources = error_sources.sort_by { |source, count| count }.reverse

    error_sources.each do |source, count|
      table << { 'Source'  => source.titleize,
                 'Error'   => nil,
                 'Count'   => nil,
                 'Percent' => nil }

      source_error_counts = OutError.created_yesterday.where(:source => source).count(:all, :group => :error)
      source_error_counts = source_error_counts.sort_by { |error, count| count}.reverse

      source_error_counts.each do |error, count|
        table << { 'Source'  => nil,
                   'Error'   => error,
                   'Count'   => count,
                   'Percent' => '%.2f%' % ((count.to_f / (source_error_counts.map { |error, count| count }.inject(:+)).to_f) * 100) }
      end
    end

    table
  end

  def self.perform
    reports = []

    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_providers_report.csv",
                 :name     => 'Provider Statistics',
                 :table    => build_providers_report }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_out_counts_report.csv",
                 :name     => 'Out Statistics',
                 :table    => build_out_counts_report }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_errors_report.csv",
                 :name     => 'Error Statistics',
                 :table    => build_errors_report }

    ReportMailer.report_email(reports).deliver
  end
end

