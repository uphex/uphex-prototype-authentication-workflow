require 'uphex/prototype/cynosure'

class GoogleTestController < ApplicationController
  get '/' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    @config=JSON.parse(File.read(File.expand_path("../../auth_config.json", __FILE__)))


    @provider=Provider.find params[:providerid].to_i

    client= Uphex::Prototype::Cynosure::Shiatsu.client(:google,@config['oauth-v2']['providers']['google']['identifier'],@config['oauth-v2']['providers']['google']['secret'])
    client.authenticate(@provider.access_token,@provider.expiration_date,@provider.refresh_token)
    @profiles= client.profiles

    if params[:profile]
      client.profile= client.profiles.select{|p| p.id==params[:profile]}.first
      @referrers=client.referrers(100.days.ago,Time.now)
      @visits_day=client.visits(100.days.ago,Time.now,:day)
      @visits_week=client.visits(100.days.ago,Time.now,:week)
      @visits_month=client.visits(100.days.ago,Time.now,:month)

      @visitors_day=client.visitors(100.days.ago,Time.now,:day)
      @visitors_week=client.visitors(100.days.ago,Time.now,:week)
      @visitors_month=client.visitors(100.days.ago,Time.now,:month)

      @bounces_day=client.bounces(100.days.ago,Time.now,:day)
      @bounces_week=client.bounces(100.days.ago,Time.now,:week)
      @bounces_month=client.bounces(100.days.ago,Time.now,:month)

    end

    haml :'google_test/show',:layout=>:'layouts/primary'
  end
end