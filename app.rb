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
    puts "params: #{params}"

    @stadiums = stadiums_table.all.to_a
    view "stadiums"
end

get "/stadiums/:id" do
    puts "params: #{params}"

    @stadium = stadiums_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(stadium_id: @stadium[:id])
    @users_table = users_table
    # using users_id: 1 as qualifier since new users cannot add stadiums, only reviews
    @chad_review = reviews_table.where(users_id: 1, stadiums_id: @stadium[:id]).to_a[0]
    @count_reviews = reviews_table.where(stadiums_id: @stadium[:id]).select { count("*") }.to_a[0]
    @average_score = reviews_table.where(stadiums_id: @stadium[:id]).select { avg(:score) }.to_a[0]

    view "stadium"
end



