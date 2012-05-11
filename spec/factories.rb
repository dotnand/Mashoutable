FactoryGirl.define do
  factory :message do
    name 'John Doe'
    subject 'Test Subject'
    email 'john.doe@localhost.com'
    body 'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...'
  end

  factory :user do
  end

  factory :authorization do
    user
    provider 'provider'
    sequence(:uid) {|n| "uid_#{n}" }
    token 'token'
    secret 'secret'
  end

  factory :mention do
    user
    out
    sequence(:who) {|n| "@mentioned_person_#{n}"}
  end

  factory :reply do
    user
    out
    sequence(:status_id) {|n| "#{n}"}
  end

  factory :bestie do
    user
    sequence(:screen_name) {|n| "@#{n}"}
  end

  factory :video do
    user
    sequence(:name) {|n| "name#{n}"}
    sequence(:guid) {|n| "video#{n}"}
  end

  factory :interaction do
    user
    out
    sequence(:content)  {|n| "content #{n}"}
    sequence(:target)   {|n| "user_#{n}"}
  end

  factory :out do
    user
    video
    twitter   { true }
    facebook  { true }
    youtube   { true }
    pending   { true }
    sequence(:trend_source) {|n| "trend_#{n}"}
    sequence(:comment)      {|n| "comment_#{n}"}
    sequence(:content)      {|n| "content_#{n}"}
  end

  factory :preference do
    user
    twitter   { false }
    facebook  { false }
    youtube   { false }
  end

  factory :verified_twitter_user do
    sequence(:user_id) {|n| n}
  end

  factory :friend do
    user
    sequence(:twitter_user_id) {|n| n}
  end

  factory :follower do
    user
    sequence(:twitter_user_id) {|n| n}
  end

  factory :trendspottr_topic do
    sequence(:name) {|n| "Trendspottr Topic #{n}"}
  end

  factory :trendspottr_search do
    sequence(:name) {|n| "Trendspottr Search #{n}"}
  end

  factory :advertisement do
    sequence(:image_path) { |n| "ad#{n}.png" }
  end

  factory :advertisement_email do
    advertisement
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end

