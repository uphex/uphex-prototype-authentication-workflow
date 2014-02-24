require 'uphex/prototype/cynosure'

class FacebookTestController < ApplicationController
  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    @providers=Provider.where(name:'facebook')

    @pages=@providers.map{|p|
      {:page=>Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil).authenticate(p.access_token).profile,:provider=>p}
    }

    if params[:provider_id]
      @provider=Provider.find params[:provider_id].to_i
      client= Uphex::Prototype::Cynosure::Shiatsu.client(:facebook,nil,nil)
      client.authenticate(@provider.access_token)
      @page_visits=client.page_visits(Time.now-60*60*24*180)
      @page_likes=client.page_likes(Time.now-60*60*24*180)
    end

    haml :'facebook_test/show',:layout=>:'layouts/primary'
  end
end