class GenerateReports
  @queue = :generate_reports_queue

  def self.yesterday
    (Time.now.yesterday.midnight)..(Time.now.midnight)
  end

  def self.out_count(user_ids, date_range = nil)
    return [0, 0, 0] if user_ids.empty?

    blastouts = Blastout.where(:user_id => user_ids)
    mashouts  = Mashout.where(:user_id => user_ids)
    shoutouts = Shoutout.where(:user_id => user_ids)

    if date_range.present?
      blastouts = blastouts.where(:created_at => date_range)
      mashouts  = mashouts.where(:created_at => date_range)
      shoutouts = shoutouts.where(:created_at => date_range)
    end

    blastouts = blastouts - blastouts.joins(:out_errors)
    mashouts  = mashouts  - mashouts.joins(:out_errors)
    shoutouts = shoutouts - shoutouts.joins(:out_errors)

    [blastouts.count, mashouts.count, shoutouts.count]
  end

  def self.build_provider_report_row(provider, user_ids, date_range = nil)
    blastout_count, mashout_count, shoutout_count = out_count(user_ids, date_range)
    { 'Provider'    => provider,
      'Blastouts'   => blastout_count,
      'Mashouts'    => mashout_count,
      'Shoutouts'   => shoutout_count }
  end

  def self.build_out_count_row(status, all, blastouts, mashouts, shoutouts)
    { 'Status'    => status,
      'All'       => all.count,
      'Blastouts' => blastouts.count,
      'Mashouts'  => mashouts.count,
      'Shoutouts' => shoutouts.count }
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

  def self.build_providers_report(date_range = nil)
    table                        = Table(['Provider', 'Accounts Created', 'Blastouts', 'Mashouts', 'Shoutouts'])
    providers                    = [Authorization::FACEBOOK,
                                    Authorization::TWITTER,
                                    [Authorization::FACEBOOK,
                                     Authorization::TWITTER]]
    users_with_one_authorization = User.joins(:authorizations)
                                       .select('"users"."id"')
                                       .group('"users"."id"')
                                       .having('count(*) = 1')
                                       .map(&:id)

    providers.each do |provider|
      if provider.is_a?(String)
        # Users that authorized this provider
        authorizations      = Authorization.joins(:user).where(:provider => provider,
                                                               :users => { :id => users_with_one_authorization })
        authorized_user_ids = authorizations.map(&:user_id)
        provider_name       = "#{provider.titleize} Only"
        report_row          = build_provider_report_row(provider_name,
                                                        authorized_user_ids,
                                                        date_range)

        if date_range.present?
          authorizations_by_date = authorizations.where(:created_at => date_range)

          report_row.merge!('Accounts Created' => authorizations_by_date.count)
        else
          report_row.merge!('Accounts Created' => authorized_user_ids.count)
        end

        table << report_row
      else
        user_ids = []

        # Get the users for each provider
        provider.each do |individual_provider|
          authorizations = Authorization.where(:provider => individual_provider)
          user_ids << authorizations.map(&:user_id)
        end

        # Intersect the users from each provider to get the users that
        # have authorized with all providers in the list
        user_ids      = user_ids.inject(:&)
        provider_name = provider.map(&:titleize).join(' + ')
        report_row    = build_provider_report_row(provider_name, user_ids, date_range)

        if date_range.present?
          user_ids_by_date = []

          provider.each do |individual_provider|
            authorizations = Authorization.where(:provider => individual_provider, :created_at => date_range)
            user_ids_by_date << authorizations.map(&:user_id)
          end

          user_ids_by_date = user_ids_by_date.inject(:&)

          report_row.merge!('Accounts Created' => user_ids_by_date.count)
        else
          report_row.merge!('Accounts Created' => user_ids.count)
        end

        table << report_row
      end
    end

    table << { 'Provider'         => 'Total',
               'Accounts Created' => table.sum('Accounts Created'),
               'Blastouts'        => table.sum('Blastouts'),
               'Mashouts'         => table.sum('Mashouts'),
               'Shoutouts'        => table.sum('Shoutouts') }

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

    table << { 'Source' => 'Total',
               'Error'  => nil,
               'Count'  => table.sum('Count'),
               'Percent' => nil }

    table
  end

  def self.perform
    reports = []

    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_providers_report_all_time.csv",
                 :name     => 'Provider Statistics ( all time )',
                 :table    => build_providers_report }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_providers_report_24_hours.csv",
                 :name     => 'Provider Statistics ( last 24 hours )',
                 :table    => build_providers_report(yesterday) }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_out_counts_report.csv",
                 :name     => 'Out Statistics ( last 24 hours )',
                 :table    => build_out_counts_report }
    reports << { :filename => "#{Time.now.strftime('%Y%m%d%H%M%S')}_errors_report.csv",
                 :name     => 'Error Statistics ( last 24 hours )',
                 :table    => build_errors_report }

    ReportMailer.report_email(reports).deliver
  end
end

