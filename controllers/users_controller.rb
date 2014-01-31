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
      @user=User.create(:email=>params[:email],:password=>Password.create(params[:password]),:verified=>false)
      env['warden'].authenticate!
      redirect '/'
    end
  end

  get '/me' do
    unless env['warden'].authenticated?
      redirect '/sessions/new'
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