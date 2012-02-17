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
    uid 'uid'
    token 'token'
    secret 'secret'
  end
  
  factory :mention do
    user
    sequence(:who) {|n| "@mentioned_person_#{n}"}
  end

  factory :reply do
    user
    sequence(:status_id) {|n| "#{n}"}
  end
  
  factory :bestie do
    user
    sequence(:screen_name) {|n| "@#{n}"}
  end
end

