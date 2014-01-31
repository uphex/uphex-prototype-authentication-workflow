require 'sinatra/base'
require 'haml'
require 'warden'
require 'bcrypt'

class ApplicationController < Sinatra::Base
  include BCrypt
  use Rack::Session::Cookie

  set :views, File.expand_path('../../views', __FILE__)
  enable :method_override

  use Warden::Manager do |manager|
    manager.default_strategies :password
    manager.failure_app = ApplicationController
    manager.serialize_into_session {|user| user.id}
    manager.serialize_from_session {|id| User.find(id)}
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params["email"] || params["password"]
    end

    def authenticate!
      user = User.find_by_email(params["email"])
      if user && Password.new(user.password)==params['password']
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  before '/*' do
    @authenticated=env['warden'].authenticated?
  end

  post '/unauthenticated' do
    redirect "/"
  end

  get '/' do
    haml :index,:layout=>:'layouts/primary'
  end

  after do
    ActiveRecord::Base.connection.close
  end
end