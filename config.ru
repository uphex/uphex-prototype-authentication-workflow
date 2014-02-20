require 'sinatra/base'
require 'active_record'

require File.expand_path("../controllers/application_controller.rb", __FILE__)
require File.expand_path("../controllers/sessions_controller.rb", __FILE__)
require File.expand_path("../controllers/users_controller.rb", __FILE__)
require File.expand_path("../controllers/verifications_controller.rb", __FILE__)
require File.expand_path("../controllers/OAuthV1AuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/OAuthV2AuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/GoogleAuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/FacebookAuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/MailchimpAuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/TwitterAuthenticationStrategy.rb", __FILE__)
require File.expand_path("../controllers/auth_controller.rb", __FILE__)
require File.expand_path("../controllers/google_test_controller.rb", __FILE__)

require File.expand_path("../models/user.rb", __FILE__)
require File.expand_path("../models/provider.rb", __FILE__)


map('/users') { run UsersController }
map('/sessions') { run SessionsController }
map('/verifications') { run VerificationsController }
map('/auth') { run AuthController }
map('/') { run ApplicationController }
map('/google_test') { run GoogleTestController }

if ENV['RACK_ENV']=='production'
  ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
else
  if ENV['RACK_ENV']=='test'
     ActiveRecord::Base.establish_connection(
         :adapter  => 'sqlite3',
         :database => ':memory:'
     )
  else
    ActiveRecord::Base.establish_connection(
        :adapter  => 'sqlite3',
        :database => 'file'
    )
  end
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