require 'bcrypt'

class SessionsController < ApplicationController
  include BCrypt

  delete '/me' do
    env['warden'].logout
    redirect '/'
  end

  get '/new' do
    haml :'sessions/new',:layout=>:'layouts/primary'
  end

  post '/' do
    env['warden'].authenticate(:password)
    if env['warden'].authenticated?
      redirect '/'
    else
      @auth_error=true
      haml :'sessions/new',:layout=>:'layouts/primary'
    end
  end
end