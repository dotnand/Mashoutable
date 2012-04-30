require 'spec_helper'

describe CacheTrendspottrPopularTrends do
  it 'should cache trends' do
    io = StringIO.new(File.read("#{Rails.root}/spec/files/trendspottr_index.html"))
    Kernel.should_receive(:open).with('http://trendspottr.com/index.php?q=technology').and_return(io)
    
    topics = ["Technology",
              "Social Media",
              "Infographic",
              "Economy",
              "Sports",
              "Pop Culture",
              "Politics",
              "Celebrity",
              "Fashion",
              "Science"]
    
    searches = ["Redes Sociales",
                "$aapl OR $msft OR $goog",
                "Local SEO",
                "John Terry",
                "#seo",
                "SEO",
                "Love",
                "Eco",
                "Android Tips",
                "Mobile Usage"]

    CacheTrendspottrPopularTrends.perform

    TrendspottrTopic.all.map(&:name).should eq(topics)
    TrendspottrSearch.all.map(&:name).should eq(searches)
  end
end
