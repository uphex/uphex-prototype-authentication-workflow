class TwitterAuthenticationStrategy < OAuthV1AuthenticationStrategy
  def callback(config,params,request,session)
    @consumer = OAuth::Consumer.new(config['consumer_key'],config['consumer_secret'],config['options'])
    @consumer.http.set_debug_output($stderr)
    @req_token = OAuth::RequestToken.new(@consumer,session[:request_token],session[:request_token_secret])

    # Request user access info from Twitter
    @access_token = @req_token.get_access_token(:oauth_verifier=>params["oauth_verifier"])

    return [].push(Hash['access_token'=>@access_token.token,'access_token_secret'=>@access_token.secret])

  end

  def sample(tokens,config)
    @consumer = OAuth::Consumer.new(config['consumer_key'],config['consumer_secret'],config['options'])
    @access_token=OAuth::AccessToken.new(@consumer,tokens[0]['access_token'],tokens[0]['access_token_secret'])
    return @access_token.request(:get, "https://api.twitter.com/1.1/statuses/home_timeline.json").body
  end
end