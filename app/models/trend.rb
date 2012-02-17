class Trend
  GOOGLE  = 'Google'
  TWITTER = 'Twitter'

  def self.trends(user, source, country = nil, woeid = nil)
    case source
      when Trend::GOOGLE then self.google
      when Trend::TWITTER then self.twitter(user, country, woeid)
      else []
    end
  end

  def self.twitter(user, country = nil, woeid = nil)
    trend_locations = user.twitter.trend_locations
    global          = trend_locations.map { |location| location.country }.unshift('Worldwide').uniq.map { |country| {:name => country, :value => country} }
    by_location     = []
    local_trends    = []
    
    if not country.nil?
      by_location = trend_locations.select { |location| location.country == country and location.name != country }.map { |location| {:name => location.name, :value => location.woeid} }
    end

    if not country.nil? and by_location.count == 1
      local_trends = user.twitter.local_trends(by_location.first[:value])
    elsif not woeid.nil?
      local_trends = user.twitter.local_trends(woeid)
    end
    
    [global.sort_by { |trend| trend[:name] }.reverse, by_location.sort_by { |trend| trend[:name] }.reverse, local_trends.map { |trend| {:name => trend.name, :value => trend.name} } ]
  end
  
  def self.google
    doc   = Nokogiri::XML(Kernel.open('http://www.google.com/trends/hottrends/atom/hourly'))
    cdata = Nokogiri::XML(doc.search('content').text)

    [[], [], cdata.xpath('//li').map{ |item| {:name => item.text, :value => item.text} }]
  end
end
