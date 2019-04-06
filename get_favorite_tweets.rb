#!/usr/bin/env ruby

require './twitter_client.rb'
require 'open-uri'

class GetFavoriteTweets

  def initialize
    @client = TwitterClient.new
    @picture_counter_hash
  end

  def fetch(url)
    p url
    html = open(url)
    body = html.read
    mime = html.content_type
    return body, mime
  end

  def check_picture_extension(mime)
    ext = ''
    if mime.include?('jpeg')
      ext = '.jpg'
    elsif mime.include?('png')
      ext = '.png'
    elsif mime.include?('gif')
      ext = '.gif'
    end
    ext
  end

  def download_tweet_picture(tweet)
    p tweet.text
    #p tweet.user.name
    #p tweet.user.screen_name
    return if tweet.media.empty?
    media_urls = tweet.media.map{|media| media.media_url.to_s}
    media_urls.each do |url|
      img,mime = fetch url
      next if mime.nil? or img.nil?
      ext = check_picture_extension(mime)
      next if ext == ''
      @picture_counter_hash[tweet.user.screen_name] = 0 unless @picture_counter_hash.has_key?(tweet.user.screen_name)
      file_name = tweet.user.screen_name + "-" + @picture_counter_hash[tweet.user.screen_name].to_s
      result_file_path = picture_dir + file_name + ext
      @picture_counter_hash[tweet.user.screen_name] += 1
      File.open(result_file_path, 'w') do |file|
        file.puts(img)
      end
      sleep(1)
    end
    # exit if picture_counter > 5 # 画像をダウンロードしたら、終了。デバッグ用
  end

  def start_download_picture
    #p client.show_my_profile
    # picture_counter = 1 #画像の名前をつけるための、暫定的なカウンター
    @picture_counter_hash = {} # 画像の名前をつけるためのカウンター。アカウント毎にカウントする
    picture_dir = 'favorite_picture/'
    Dir.mkdir(picture_dir) unless File.exist?(picture_dir) # フォルダの作成
    page = 1
    until (favorites = @client.favorite(20,page)).nil? do
      favorites.each do |tweet|
        download_tweet_picture tweet
      end
      page += 1
    end
  end

  def output_tweet
    page = 1
    until (favorites = @client.favorite(20,page)).nil? do
      favorites.each do |tweet|
        File.open("favorite_tweets.md", 'a') do |file|
          file.print("###" + tweet.user.name)
          file.puts('(@' + tweet.user.screen_name + ')')
          text = tweet.text
          text = text.gsub(/#/,"\\#")
          file.puts(text)
          unless tweet.media.empty?
            file.puts("  ")
            media_urls = tweet.media.map{|media| media.media_url.to_s}
            media_urls.each do |url|
              file.puts("![](#{url})  ")
            end
          end
          file.puts("")
        end
      end
      page += 1
      break # for debug
    end
  end

end

a = GetFavoriteTweets.new
# a.start_download_picture
a.output_tweet
