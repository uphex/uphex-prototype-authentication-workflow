require 'sinatra/base'
require 'active_record'

require './controllers/application_controller.rb'
require './controllers/sessions_controller.rb'
require './controllers/users_controller.rb'
require './controllers/auth_controller.rb'

Dir.glob('./{models,helpers}/*.rb').each { |file| require file }


map('/users') { run UsersController }
map('/sessions') { run SessionsController }
map('/auth') { run AuthController }
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
    end
  end
  unless ActiveRecord::Base.connection.tables.include? 'providers'
    create_table :providers do |table|
      table.column :name,     :string
      table.column :userid, :number
      table.column :access_token, :string
      table.column :expiration_date, :date
      table.column :token_type, :string
      table.column :refresh_token, :string
      table.column :raw_response, :string

    end
  end
end