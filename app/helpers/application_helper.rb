module ApplicationHelper
  def twitter_auth_path
   '/auth/twitter'
  end
  
  def facebook_auth_path
    '/auth/facebook'
  end
  
  def group_hash_by(hashes, group_by)
    return nil if hashes.nil?
  
    grouped = {}
    hashes.each do |element|
      key = element[group_by.to_sym]
      grouped[key] ||= []
      grouped[key] << element;
    end
    grouped    
  end
  
  def on_dashboard_index?
    controller.controller_name == 'dashboard' and controller.action_name == 'index'
  end

  def conditional_div(condition, attributes, &block)
    if condition
      haml_tag :div, attributes, &block
    else
      haml_concat capture_haml(&block)
    end
  end
  
  def sanitize_twitter_screen_name(screen_name)
    screen_name.gsub(/[^0-9a-z\-\_]+/i, '')
  end
end
