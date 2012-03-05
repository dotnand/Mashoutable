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

  def large_content?
    if controller.controller_name == 'dashboard' and ['video_playback', 'index'].include?(controller.action_name)
      return true
    elsif
      controller.controller_name == 'content' and ['about_us', 'blog', 'contact_us', 'mashout', 'blastout', 'pickout', 'shoutout'].include?(controller.action_name)
      return true
    end
    return false
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

