require 'optparse'
require 'sinatra'
require 'yajl/json_gem'

puts " __                  __ __             _______ _______ "
puts "|  |--..-----..----.|  |__|.-----.    |   _   |_     _|"
puts "|  _  ||  -__||   _||  |  ||     |    |       |_|   |_ "
puts "|_____||_____||__|  |__|__||__|__|    |___|___|_______|"
puts

%w(game map node).each do |file|
  require File.expand_path( File.dirname( __FILE__ ) ) + "/ai/#{file}"
end

# Parse options
OptionParser.new do |opts|
  opts.on("-p N", "--port=N", Integer, "Set running port to N") do |p|
    set :port, p
  end
  
  opts.on("--debug", "Run in debug mode (reloads code at each request)") do |d|
    if d
      require 'sinatra/reloader'
      
      configure do |c|
        c.also_reload $0
      end
    end
  end
end.parse!

# Sinatra options
set :app_file, $0

post '/' do
  begin
    # Check if it's one of the four Berlin keywords
    if ['ping', 'turn', 'game_start', 'game_over'].include? params[:action]
      game = Berlin::AI::Game.create_or_update params[:action], params[:infos], params[:map], params[:state]

      if ['ping', 'turn'].include? params[:action]
        # Let the player decides his moves
        Berlin::AI::Player.on_turn( game )
        
        # Return the response to Berlin
        return game.moves.to_json
      end
    else
      p params.inspect
    end

    # For every other type of request, respond with 200 OK
    200
  rescue Exception => e
    p e.inspect
    p e.backtrace
    
    # Internal server error
    500
  end
end
