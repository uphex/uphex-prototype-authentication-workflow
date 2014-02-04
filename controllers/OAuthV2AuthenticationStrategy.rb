require 'rack/oauth2'
class OAuthV2AuthenticationStrategy
  def getRedirectUri(config,request,session)
    client = Rack::OAuth2::Client.new(
        :identifier => config['identifier'],
        :secret => config['secret'],
        :redirect_uri => request.url+'/callback', # only required for grant_type = :code
        :host => config['host'],
        :authorization_endpoint=>config['authorization_endpoint']
    )

    url=client.authorization_uri(config['authorization_params'])

    return url
  end
  def callback(config,params,request,session)
    if request.port!=80
      @url=request.scheme.to_s+'://'+request.host.to_s+':'+request.port.to_s+request.path.to_s
    else
      @url=request.scheme.to_s+'://'+request.host.to_s+request.path.to_s
    end

    client = Rack::OAuth2::Client.new(
        :identifier => config['identifier'],
        :secret => config['secret'],
        :redirect_uri => @url, # only required for grant_type = :code
        :host => config['token_host'],
        :token_endpoint=>config['token_endpoint']
    )

    client.authorization_code = params[:code]

    Rack::OAuth2.debugging =true

    @token=client.access_token!(:authorization_code)
  end
end