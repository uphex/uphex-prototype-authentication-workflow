class FacebookAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    rsp=Rack::OAuth2.http_client.get('https://graph.facebook.com/me/accounts',[],:Authorization=>'Bearer '+@token.access_token)

    json=JSON.parse(rsp.body)

    res=[]
    json['data'].map{|d|
      long_lived_token=Rack::OAuth2.http_client.get('https://graph.facebook.com/oauth/access_token?client_id=701079439943046&client_secret=d2778ab9e6deedea51292cbed1bd05ad&redirect_uri='+@url+'&grant_type=fb_exchange_token&fb_exchange_token='+d['access_token'],[],:Authorization=>'Bearer '+@token.access_token).body.split('=',2)[1]

      res.push(Hash['access_token'=>long_lived_token,'expiration_date'=>nil,'refresh_token'=>nil,'pageid'=>d['id']])
    }

    return res
  end

  def sample(tokens,options)
    @rsp=[]
    tokens.each{|token|
      rsp=Rack::OAuth2.http_client.get('https://graph.facebook.com/'+token['pageid']+'/insights',[],:Authorization=>'Bearer '+token['access_token'])
      @rsp.push rsp.body
    }

    return @rsp
  end
end