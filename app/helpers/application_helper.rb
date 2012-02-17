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
end
