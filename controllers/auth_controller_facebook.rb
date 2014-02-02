require 'rack/oauth2'
require 'json'

class FacebookAuthController < ApplicationController

  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    client = Rack::OAuth2::Client.new(
        :identifier => '701079439943046',
        :secret => 'd2778ab9e6deedea51292cbed1bd05ad',
        :redirect_uri => request.url+'/callback', # only required for grant_type = :code
        :host => 'www.facebook.com',
        :authorization_endpoint=>'/dialog/oauth'
    )

    url=client.authorization_uri(:scope=>'manage_pages,read_insights')

    puts url

    redirect url
  end

  get '/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    if request.port!=80
      url=request.scheme.to_s+'://'+request.host.to_s+':'+request.port.to_s+request.path.to_s
    else
      url=request.scheme.to_s+'://'+request.host.to_s+request.path.to_s
    end
    client = Rack::OAuth2::Client.new(
        :identifier => '701079439943046',
        :secret => 'd2778ab9e6deedea51292cbed1bd05ad',
        :redirect_uri => url, # only required for grant_type = :code
        :host => 'graph.facebook.com',
        :token_endpoint=>'/oauth/access_token'
    )

    client.authorization_code = params[:code]

    Rack::OAuth2.debugging =true

    #first
    token=client.access_token!(:authorization_code)
    #till

    rsp=Rack::OAuth2.http_client.get('https://graph.facebook.com/me/accounts',[],:Authorization=>'Bearer '+token.access_token)

    json=JSON.parse(rsp.body)
    @rsp=[]

    json['data'].each{|d|
      id=d['id']
      long_lived_token=Rack::OAuth2.http_client.get('https://graph.facebook.com/oauth/access_token?client_id=701079439943046&client_secret=d2778ab9e6deedea51292cbed1bd05ad&redirect_uri='+url+'&grant_type=fb_exchange_token&fb_exchange_token='+d['access_token'],[],:Authorization=>'Bearer '+token.access_token).body.split('=',2)[1]

      rsp=Rack::OAuth2.http_client.get('https://graph.facebook.com/'+id+'/insights',[],:Authorization=>'Bearer '+long_lived_token)

      @rsp.push rsp.body
      @provider=Provider.create(:name=>'facebook',:userid=>env['warden'].user.id,:access_token=>long_lived_token,:token_type=>'access',:raw_response=>'TODO')
    }

    haml :'auth/oauth_v2/facebook/callback',:layout=>:'layouts/primary'

  end
end