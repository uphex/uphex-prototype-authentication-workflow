require 'uphex/prototype/cynosure'

class TwitterTestController < ApplicationController
  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    @config=JSON.parse(File.read(File.expand_path("../../auth_config.json", __FILE__)))


    @provider=Provider.find params[:providerid].to_i

    client= Uphex::Prototype::Cynosure::Shiatsu.client(:twitter,@config['oauth-v1']['providers']['twitter']['consumer_key'],@config['oauth-v1']['providers']['twitter']['consumer_secret'])
    client.authenticate(@provider.access_token,@provider.access_token_secret)
    @tweets= client.tweets

    @followers_count=client.followers_count
    @user_following_count=client.user_following_count

    if params[:tweet_id]
      @retweets_count=client.retweets_count(params[:tweet_id])
      @retweets=client.retweets(params[:tweet_id])
      @favorites_count=client.favorites_count(params[:tweet_id])
    end

    haml :'twitter_test/show',:layout=>:'layouts/primary'
  end
end