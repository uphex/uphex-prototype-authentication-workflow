class GoogleAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    return [].push(Hash['access_token'=>@token.access_token,'expiration_date'=>Time.now+@token.expires_in.to_i,'refresh_token'=>@token.refresh_token])
  end

  def sample(tokens,options)
    Rack::OAuth2.http_client.get('https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A44409454&dimensions=ga%3Ayear&metrics=ga%3Avisits&start-date=2014-02-11&end-date=2014-02-18&max-results=50',[],:Authorization=>'Bearer '+tokens[0]['access_token']).body
  end
end