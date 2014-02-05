ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'

describe 'Uphex Auth App' do

  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first
  end

  it 'navigates with anonymous user' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Sign up')
    get '/sessions/new'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Sign in')
    get '/users/new'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Send')

    get 'users/me'
    last_response.should be_redirect
  end

  it 'signs up and logs out then signs in again' do
    get '/users/new'
    post '/users',{'email'=>'test@test.com','password'=>'password','repassword'=>'password'}
    last_response.should be_redirect

    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Log out')

    get '/users/me'
    expect(last_response.body).to include('test@test.com')

    post '/sessions/me',{'_method'=>'DELETE'}
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Sign in')

    post '/sessions',{'email'=>'test@test.com','password'=>'wrong_password'}
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Sign in')

    post '/sessions',{'email'=>'test@test.com','password'=>'password'}
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Log out')
  end

  it 'signs up and verifies email' do
    post '/users',{'email'=>'test2@test.com','password'=>'password','repassword'=>'password'}

    get '/users/me'
    expect(last_response.body).to include('Verified: f')


    user=User.find_by_email('test2@test.com')
    get '/verifications/',{'verification_id'=>"#{user.id}_#{user.verification_id}"}
    follow_redirect!
    expect(last_response.body).to include('Verification successful')

    get '/users/me'
    expect(last_response.body).not_to include('Verified: f')
  end

  it 'gets redirected to the appropriate service' do
    post '/users',{'email'=>'test3@test.com','password'=>'password','repassword'=>'password'}
    get '/auth/oauth-v2/google'
    last_response.should be_redirect
    expect(last_response.location).to include('accounts.google.com')

    get '/auth/oauth-v2/facebook'
    last_response.should be_redirect
    expect(last_response.location).to include('facebook')

    get '/auth/oauth-v1/twitter'
    last_response.should be_redirect
    expect(last_response.location).to include('api.twitter.com')

    get '/auth/oauth-v2/mailchimp'
    last_response.should be_redirect
    expect(last_response.location).to include('login.mailchimp.com')


  end

end