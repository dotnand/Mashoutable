class ContentController < ApplicationController
  def home
    render :layout => 'application'
  end
  
  def about_us
  end
  
  def blog
  end
  
  def contact_us
    @message = Message.new
  end
  
  def message
    @message = Message.new(params[:message])
    
    if @message.valid?
      ContactMailer.new_message(@message).deliver
      flash.now[:notice] = "Message was successfully sent."
    else
      flash.now[:error] = "Please fill all fields and make sure they are valid."
    end

    render :contact_us
  end
end
