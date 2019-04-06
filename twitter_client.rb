require 'twitter'
require 'dotenv'
Dotenv.load

class TwitterClient
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["CONSUMER_KEY"]
      config.consumer_secret = ENV["CONSUMER_SECRET"]
      config.access_token = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end
  end

  def show_my_profile
    puts @client.user.screen_name # アカウントID
    puts @client.user.name # アカウント名
    puts @client.user.description # プロフィール
    puts @client.user.tweets_count # ツイート数
    puts @client.user.favorites_count # お気に入りの数
  end

  def get_my_profile
    @client.user
  end

  def show_timeline
    @client.home_timeline.each do |tweet|
      puts tweet.full_text
      puts "FAVORITE: #{tweet.favorite_count}"
      puts "RETWEET : #{tweet.retweet_count}"
    end
  end

  def get_timeline
    @client.home_timeline
  end

  def favorite(num=20,page=1)
    # pageを指定すると、より過去のお気に入りツイートが見れる
    #@client.favorites({count: num, page: page}).each do |tweet|
    #  p tweet.text
    #  p tweet.media
    #  p tweet.id
    #end
    begin
      @client.favorites({count: num, page: page})
    rescue Twitter::Error::TooManyRequests => error
      #p error.rate_limit.reset_in
      STDERR.puts "Twitter::Error::TooManyRequests while getting favorite tweets."
      sleep error.rate_limit.reset_in # APIの規制が解除されるまでsleep
      retry
    rescue Net::OpenTimeout
      STDERR.puts "Twitter::Error::Net::OpenTimeout while getting favorite tweets."
    end
  end

  def all_favorites
    @client.favorites({count: @client.user.favorites_count}).each_with_index do |tweet, i|
      p i
      p tweet.text
      p tweet.media
    end
  end

  def favorite_pictures(num=20)
    @client.favorites({count: num}).flat_map{|tweet| tweet.media}.map{|media| media.media_url.to_s}
  end

  def show_user_tweets(user_id,num=20)
    @client.user_timeline(user_id, {count: num}).each do |tweet|
      p tweet.created_at # class is Time
      p tweet.text
      #p @client.status(tweet.id).text
    end
  end

  def get_user_tweets_media(user_id,num=20)
    tweets = @client.user_timeline(user_id, {count: num})
    p tweets.flat_map{|s| s.media}.map{|m| m.media_url.to_s}
  end

end

#client = TwitterClient.new
#p client.favorite_pictures
#client.all_favorites
#client.favorite(20,50)
#client.show_user_tweets("satoukabi", 5)
#client.get_user_tweets_media("satoukabi", 50)
#client.show_my_profile
#client.show_timeline
