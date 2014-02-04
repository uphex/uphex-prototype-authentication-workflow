class MailchimpAuthenticationStrategy < OAuthV2AuthenticationStrategy
  def callback(config,params,request,session)
    super

    return [].push(Hash['access_token'=>@token.access_token])
  end

  def sample(tokens,options)
    Rack::OAuth2.http_client.get('https://login.mailchimp.com/oauth2/metadata',[],:Authorization=>'Bearer '+tokens[0]['access_token']).body
  end
end