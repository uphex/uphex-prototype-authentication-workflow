require 'sinatra/base'
require 'active_record'

Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }


map('/users') { run UsersController }
map('/sessions') { run SessionsController }
map('/') { run ApplicationController }

ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'file'
)
ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'users'
    create_table :users do |table|
      table.column :email,     :string
      table.column :password, :string
      table.column :verified, :bool
    end
  end
end