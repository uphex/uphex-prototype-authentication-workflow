class VerificationsController < ApplicationController

  get '/' do
    (userid,verification_id)=params[:verification_id].split('_',2)
    @user=User.find(userid)
    if @user.verification_id === verification_id
      @user.update(:verified=>true)
      redirect '/users/me?verification_successful=true'
    else
      status 404
    end

  end
end