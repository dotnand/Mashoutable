require "spec_helper"

describe ContactMailer do
  it 'should build an email' do
    message = FactoryGirl.build(:message)
    mail    = ContactMailer.new_message(message)

    mail.subject.should eq("Mashoutable.com message: #{message.name} #{message.subject}")
    mail.from.should include(message.email)
    mail.body.should eq(message.body)
    mail.to.should include('contact@mashoutable.info')
  end
end

