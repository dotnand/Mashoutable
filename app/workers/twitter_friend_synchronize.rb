class TwitterFriendSynchronize
  @queue = :twitter_friend_synchronize_queue
   
  def self.perform(user_id)
    user                = User.find(user_id)
    local_friend_ids    = user.local_friend_ids
    twitter_friend_ids  = user.twitter_ids(:friend_ids, {}, nil)

    do_not_remove_list  = local_friend_ids & twitter_friend_ids
    add_list            = (twitter_friend_ids - do_not_remove_list) - local_friend_ids
    remove_list         = local_friend_ids - twitter_friend_ids

    ActiveRecord::Base.transaction do
      remove_list.each { |id| user.friends.where(:twitter_user_id => id).each { |friend| friend.destroy } }
    end    

    ActiveRecord::Base.transaction do
      add_list.each { |id| user.friends.create(:twitter_user_id => id) }
    end

    Resque.remove_delayed(TwitterFriendSynchronize, user.id)
    Resque.enqueue_at(6.hours.from_now, TwitterFriendSynchronize, user.id)
  end
end
