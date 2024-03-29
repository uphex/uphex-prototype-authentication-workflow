class AuthController < ApplicationController

  def read_config
    @config = JSON.parse(File.read(File.expand_path("../../auth_config.json", __FILE__)))

    case @config[params[:authstrategy]]['providers'][params[:provider]]['instantiateClass']
      when 'GoogleAuthenticationStrategy'
        @authenticationStrategy=GoogleAuthenticationStrategy.new
      when 'FacebookAuthenticationStrategy'
        @authenticationStrategy=FacebookAuthenticationStrategy.new
      when 'MailchimpAuthenticationStrategy'
        @authenticationStrategy=MailchimpAuthenticationStrategy.new
      when 'TwitterAuthenticationStrategy'
        @authenticationStrategy=TwitterAuthenticationStrategy.new
    end
  end

  get '/:authstrategy/:provider' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    read_config

    redirect @authenticationStrategy.getRedirectUri(@config[params[:authstrategy]]['providers'][params[:provider]],request,session)
  end

  get '/:authstrategy/:provider/callback' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    read_config

    tokens=@authenticationStrategy.callback(@config[params[:authstrategy]]['providers'][params[:provider]],params,request,session)
    puts tokens

    tokens.each{|token|
      @provider=Provider.create(:name=>params[:provider],:userid=>env['warden'].user.id,:access_token=>token['access_token'],:access_token_secret=>token['access_token_secret'],:expiration_date=>token['expiration_date'],:token_type=>'access',:refresh_token=>token['refresh_token'],:raw_response=>'TODO')
    }

    @rsp=@authenticationStrategy.sample(tokens,@config[params[:authstrategy]]['providers'][params[:provider]])


    haml :'auth/callback',:layout=>:'layouts/primary'

    #refresh
    #client.refresh_token =token.refresh_token

    #token2=client.access_token!(:refresh_token)
    #till

  end
end