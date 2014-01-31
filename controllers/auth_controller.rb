require 'rack/oauth2'

class AuthController < ApplicationController

  get '/oauth-v2/google' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    client = Rack::OAuth2::Client.new(
        :identifier => '1011373896516-52e40da4vb1plati9sv088tdg80l5efk.apps.googleusercontent.com',
        :secret => 'YlBuX-K9Bn5P9eFnM6O4jC6c',
        :redirect_uri => request.url+'/callback', # only required for grant_type = :code
        :host => 'accounts.google.com',
        :authorization_endpoint=>'/o/oauth2/auth'
    )

    url=client.authorization_uri(:scope => 'https://www.googleapis.com/auth/analytics.readonly',:access_type=>'offline')

    puts url

    redirect url
  end

  get '/oauth-v2/google/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    if request.port!=80
      url=request.scheme.to_s+'://'+request.host.to_s+':'+request.port.to_s+request.path.to_s
    else
      url=request.scheme.to_s+'://'+request.host.to_s+request.path.to_s
    end

    client = Rack::OAuth2::Client.new(
        :identifier => '1011373896516-52e40da4vb1plati9sv088tdg80l5efk.apps.googleusercontent.com',
        :secret => 'YlBuX-K9Bn5P9eFnM6O4jC6c',
        :redirect_uri => url, # only required for grant_type = :code
        :host => 'accounts.google.com',
        :token_endpoint=>'/o/oauth2/token'
    )

    client.authorization_code = params[:code]

    Rack::OAuth2.debugging =true

    #first
    token=client.access_token!(:authorization_code)
    #till

    if token.refresh_token
      @provider=Provider.create(:name=>'google',:userid=>env['warden'].user.id,:access_token=>token.access_token,:expiration_date=>token.expires_in,:token_type=>'access',:refresh_token=>token.refresh_token,:raw_response=>'TODO')
      @success=true
      rsp=Rack::OAuth2.http_client.get('https://www.googleapis.com/analytics/v3/management/accounts',[],:Authorization=>'Bearer '+token.access_token)
      @rsp=rsp.body
    else
      @success=false;
    end

    haml :'auth/oauth_v2/callback',:layout=>:'layouts/primary'

    #refresh
    #client.refresh_token =token.refresh_token

    #token2=client.access_token!(:refresh_token)
    #till

  end
end