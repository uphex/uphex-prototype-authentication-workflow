require 'oauth'
class OAuthV1AuthenticationStrategy

  def getRedirectUri(config,request,session)
    @consumer = OAuth::Consumer.new(config['consumer_key'],config['consumer_secret'],config['options'])
    @consumer.http.set_debug_output($stderr)
    @req_token = @consumer.get_request_token(:oauth_callback=>request.url+'/callback')

    session[:request_token] = @req_token.token
    session[:request_token_secret] = @req_token.secret
    return @req_token.authorize_url
  end
end