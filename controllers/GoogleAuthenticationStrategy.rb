class GoogleAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    return [].push(Hash['access_token'=>@token.access_token,'expiration_date'=>Time.now+@token.expires_in.to_i,'refresh_token'=>@token.refresh_token])
  end

  def sample(tokens,options)
    Rack::OAuth2.http_client.get('https://www.googleapis.com/analytics/v3/management/accounts',[],:Authorization=>'Bearer '+tokens[0]['access_token']).body
  end
end