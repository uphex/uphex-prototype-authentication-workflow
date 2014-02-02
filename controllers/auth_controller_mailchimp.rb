require 'rack/oauth2'

class MailchimpAuthController < ApplicationController

  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    client = Rack::OAuth2::Client.new(
        :identifier => '645522515056',
        :secret => 'e383ff28e4d1ca6a9c1b573951d8125f',
        :redirect_uri => request.url+'/callback', # only required for grant_type = :code
        :host => 'login.mailchimp.com',
        :authorization_endpoint=>'/oauth2/authorize'
    )

    url=client.authorization_uri

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
        :identifier => '645522515056',
        :secret => 'e383ff28e4d1ca6a9c1b573951d8125f',
        :redirect_uri => url, # only required for grant_type = :code
        :host => 'login.mailchimp.com',
        :token_endpoint=>'/oauth2/token'
    )

    client.authorization_code = params[:code]

    Rack::OAuth2.debugging =true

    #first
    token=client.access_token!(:authorization_code)
    #till

    @provider=Provider.create(:name=>'mailchimp',:userid=>env['warden'].user.id,:access_token=>token.access_token,:token_type=>'access',:raw_response=>'TODO')
    rsp=Rack::OAuth2.http_client.get('https://login.mailchimp.com/oauth2/metadata',[],:Authorization=>'Bearer '+token.access_token)
    @rsp=rsp.body

    haml :'auth/oauth_v2/mailchimp/callback',:layout=>:'layouts/primary'

    #refresh
    #client.refresh_token =token.refresh_token

    #token2=client.access_token!(:refresh_token)
    #till

  end
end