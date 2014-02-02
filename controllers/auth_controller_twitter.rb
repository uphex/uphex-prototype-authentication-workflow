require 'oauth'

class TwitterAuthController < ApplicationController

  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    @consumer = OAuth::Consumer.new("xWSlyE7nsL5fs1QH9NuNg","ksUpwzpCNiEZxfuhQ2UteoThbdm64k5b6V5X2dlU8g",{:site=>"https://api.twitter.com/" })
    @consumer.http.set_debug_output($stderr)
    @req_token = @consumer.get_request_token(:oauth_callback=>request.url+'/callback')

    session[:request_token] = @req_token.token
    session[:request_token_secret] = @req_token.secret
    redirect @req_token.authorize_url

    end

  get '/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    @consumer = OAuth::Consumer.new("xWSlyE7nsL5fs1QH9NuNg","ksUpwzpCNiEZxfuhQ2UteoThbdm64k5b6V5X2dlU8g",{:site=>"https://api.twitter.com/" })
    @consumer.http.set_debug_output($stderr)
    @req_token = OAuth::RequestToken.new(@consumer,session[:request_token],session[:request_token_secret])

    # Request user access info from Twitter
    @access_token = @req_token.get_access_token(:oauth_verifier=>params["oauth_verifier"])

    response = @access_token.request(:get, "https://api.twitter.com/1.1/statuses/home_timeline.json")

    @rsp=response.body

    @provider=Provider.create(:name=>'twitter',:userid=>env['warden'].user.id,:access_token=>@access_token.token,:token_type=>'access',:access_token_secret=>@access_token.secret,:raw_response=>'TODO')

    haml :'auth/oauth_v1/twitter/callback',:layout=>:'layouts/primary'

  end
end