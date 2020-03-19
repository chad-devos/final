# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"   
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :stadiums do
  primary_key :id
  String :stadium_name
  String :description, text: true
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :stadiums_id
  foreign_key :users_id
  String :date_visited
  Integer :score
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :first_name
  String :last_name
  String :email
  String :password
end

# Insert initial (seed) data
stadiums_table = DB.from(:stadiums)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

stadiums_table.insert(stadium_name: "Petco Park", 
                    description: "MLB stadium and concert venue. Home of the San Diego Padres",
                    location: "San Diego, CA")

stadiums_table.insert(stadium_name: "Staples Center", 
                    description: "NBA arena, NHL arena, and concert venue. Home of the Los Angeles Lakers, Los Angeles Clippers, and Los Angeles Kings",
                    location: "Los Angeles, CA")

stadiums_table.insert(stadium_name: "Fenway Park", 
                    description: "MLB stadium and concert venue. Home of the Boston Red Sox. One of the league's oldest and most iconic stadiums.",
                    location: "Boston, MA")

stadiums_table.insert(stadium_name: "Qualcomm Stadium", 
                    description: "NFL and college football stadium. Former home of the Chargers and home of the SDSU Aztecs.",
                    location: "San Diego, CA")

stadiums_table.insert(stadium_name: "Angel Stadium", 
                    description: "MLB stadium and concert venue. Home of the Los Angeles Angels of Anaheim.",
                    location: "Anaheim, CA")

reviews_table.insert(stadiums_id: 1,
                    users_id: 1,
                    date_visited: "June 29, 2019",
                    Score: 9,
                    Comments: "Great stadium, great food! Have visited many times and highly recommend.")

reviews_table.insert(stadiums_id: 2,
                    users_id: 1,
                    date_visited: "December 30, 2014",
                    Score: 7.5,
                    Comments: "Went for a Laker's game and had a great experience. Feels like much more of a place to be seen than most sports venues.")

reviews_table.insert(stadiums_id: 3,
                    users_id: 1,
                    date_visited: "October 11, 2010",
                    Score: 9,
                    Comments: "An amazing experience. Most enthusiastic fans I have ever been around. Made for a great time!")
reviews_table.insert(stadiums_id: 4,
                    users_id: 1,
                    date_visited: "November 15, 2016",
                    Score: 3,
                    Comments: "Been for multiple events. The stadium is a concrete mess and should be torn down.")

reviews_table.insert(stadiums_id: 5,
                    users_id: 1,
                    date_visited: "October 10, 2009",
                    Score: 7,
                    Comments: "The stadium itself is pretty nice, but not spectactular. Went for an Angel's playoff game which was great and full of energy.")


users_table.insert(first_name: "Chad",
                last_name: "DeVos",
                email: "csdevos7@gmail.com",
                password: BCrypt::Password.create("seedaccount"))
