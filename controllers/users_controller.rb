require 'bcrypt'
require 'pony'

class UsersController < ApplicationController
  include BCrypt


  get '/new' do
    haml :'users/new',:layout=>:'layouts/primary'
  end

  post '/' do
    @email_taken_error= User.exists?(:email=>params[:email])
    if params[:password].empty?
      @password_empty_error=true
    end
    if params[:password]!=params[:repassword]
      @repassword_not_match_error=true
    end

    if @email_taken_error || @password_empty_error || @repassword_not_match_error
      haml :'users/new',:layout=>:'layouts/primary'
    else
      verification_id=SecureRandom.hex

      @user=User.create(:email=>params[:email],:password=>Password.create(params[:password]),:verified=>false,:verification_id=>verification_id)
      env['warden'].authenticate!
      if request.port!=80
        url=request.scheme.to_s+'://'+request.host.to_s+':'+request.port.to_s
      else
        url=request.scheme.to_s+'://'+request.host.to_s
      end



      Pony.mail({
                    :to => params[:email],
                    :subject => 'Verify your email',
                    :body => "Your verification url is: #{url}/verifications?verification_id=#{@user.id}_#{verification_id}",
                    :via => :smtp,
                    :via_options => {
                        :address              => 'smtp.gmail.com',
                        :port                 => '587',
                        :enable_starttls_auto => true,
                        :user_name            => 'testuphex',
                        :password             => 'n69C9FbM45C5S9rB',
                        :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
                        :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
                    }
                })
      redirect '/'
    end
  end



  get '/me' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
    end

    if params[:verification_successful]
      @verification_successful=true
    end

    @currentuser=env['warden'].user

    @providers= Provider.where(:userid=>@currentuser.id)

    haml :'users/show',:layout=>:'layouts/primary'
  end

  get '/:id' do
    @userid=params[:id]
    haml :'users/show',:layout=>:'layouts/primary'
  end
end