# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

stadiums_table = DB.from(:stadiums)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

get "/" do
    puts stadiums_table.all
    @stadiums = stadiums_table.all.to_a
    view "stadiums"
end

get "/stadiums/:id" do
    @stadium = stadiums_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(stadium_id: @stadium[:id])
    @users_table = users_table
    view "stadium"
end