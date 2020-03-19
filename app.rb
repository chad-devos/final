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

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

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

get "/stadiums/:id/reviews/new" do
    puts "params: #{params}"

    @stadium = stadiums_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

post "/stadiums/:id/reviews/create" do
    puts "params: #{params}"

    # first find the event that rsvp'ing for
    @stadium = stadiums_table.where(id: params[:id]).to_a[0]
    # next we want to insert a row in the rsvps table with the rsvp form data
    reviews_table.insert(
        stadiums_id: @stadium[:id],
        users_id: session["user_id"],
        date_visited: params["date_visited"],
        comments: params["comments"],
        score: params["score"]
    )

    redirect "/stadiums/#{@stadium[:id]}"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts "params: #{params}"

    # if there's already a user with this email, skip!
    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            first_name: params["first_name"],
            last_name: params["last_name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
        )
        redirect "/logins/new"
    end
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"

    # step 1: user with the params["email"] ?
    @user = users_table.where(email: params["email"]).to_a[0]

    if @user
        # step 2: if @user, does the encrypted password match?
        if BCrypt::Password.new(@user[:password]) == params["password"]
            # set encrypted cookie for logged in user
            session["user_id"] = @user[:id]
            redirect "/"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

get "/logout" do
    # remove encrypted cookie for logged out user
    session["user_id"] = nil
    redirect "/logins/new"
end




