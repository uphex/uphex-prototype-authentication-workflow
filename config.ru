require 'sinatra/base'
require 'active_record'

require './controllers/application_controller.rb'
require './controllers/sessions_controller.rb'
require './controllers/users_controller.rb'
require './controllers/verifications_controller.rb'
require './controllers/auth_controller_google.rb'
require './controllers/auth_controller_twitter.rb'
require './controllers/auth_controller_facebook.rb'
require './controllers/auth_controller_mailchimp.rb'

Dir.glob('./{models,helpers}/*.rb').each { |file| require file }


map('/users') { run UsersController }
map('/sessions') { run SessionsController }
map('/verifications') { run VerificationsController }
map('/auth/oauth-v2/google') { run GoogleAuthController }
map('/auth/oauth-v1/twitter') { run TwitterAuthController }
map('/auth/oauth-v2/facebook') { run FacebookAuthController }
map('/auth/oauth-v2/mailchimp') { run MailchimpAuthController }
map('/') { run ApplicationController }

if ENV['RACK_ENV']=='production'
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
else
  ActiveRecord::Base.establish_connection(
      :adapter  => 'sqlite3',
      :database => 'file'
  )
end

ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'users'
    create_table :users do |table|
      table.column :email,     :string
      table.column :password, :string
      table.column :verified, :bool
      table.column :verification_id, :string
    end
  end
  unless ActiveRecord::Base.connection.tables.include? 'providers'
    create_table :providers do |table|
      table.column :name,     :string
      table.column :userid, :numeric
      table.column :access_token, :string
      table.column :access_token_secret, :string
      table.column :expiration_date, :date
      table.column :token_type, :string
      table.column :refresh_token, :string
      table.column :raw_response, :string

    end
  end
end