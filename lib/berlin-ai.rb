require 'optparse'
require 'sinatra'
require 'logger'
require 'yajl/json_gem'

puts " __                  __ __             _______ _______ "
puts "|  |--..-----..----.|  |__|.-----.    |   _   |_     _|"
puts "|  _  ||  -__||   _||  |  ||     |    |       |_|   |_ "
puts "|_____||_____||__|  |__|__||__|__|    |___|___|_______|"
puts

%w(game_internal game map_internal map node_internal node fake).each do |file|
  require File.expand_path(File.dirname( __FILE__ )) + "/ai/#{file}"
end

set :verbose, true
set :logger, Logger.new(STDOUT)

# set tests to false
$test_ais = false

# Parse options
OptionParser.new do |opts|
  opts.on("-h", "--help", "Display this screen" ) do
    puts opts
    exit
  end

  opts.on("-p N", "--port N", Integer, "Set running port to N") do |p|
    set :port, p
  end

  opts.on("-d", "--debug", "Run in debug mode (reloads code at each request)") do
    require 'sinatra/reloader'

    configure do |c|
      c.also_reload $0
    end
  end

  opts.on("-l", "--log [LOGFILE]", "Create a log file for incoming requests (defaults to 'berlin.log')") do |l|
    set :logger, Logger.new(l || 'berlin.log')
  end

  opts.on("-t N", "--test N", Integer, "Test against N random AI") do |t|
    if t < 0 || t > 3
      puts "This map supports a maximum of 3 AI"
      exit 1
    end
    $test_ais = t
  end

  opts.on("-v", "--verbose", "Print information to STDOUT") do
    enable :verbose
  end
end.parse!

post '/' do
  begin
    # Check if it's one of the four Berlin keywords
    if ['ping', 'turn', 'game_start', 'game_over'].include?(params[:action])
      log :info, "New request of type #{params[:action]} : #{params.inspect}"

      game = Berlin::AI::Game.create_or_update(params[:action], params[:infos], params[:map], params[:state])

      if ['ping', 'turn'].include?(params[:action])
        # Clear old moves
        game.reset!

        # Let the player decides his moves
        Berlin::AI::Player.on_turn(game)

        # Get moves from AI
        moves = game.moves.to_json

        # Log time!
        log :info, "Respond with: #{moves}"

        # Return the response to Berlin
        return moves
      end
    else
      log :error, params.inspect
    end

    # For every other type of request, respond with 200 OK
    200
  rescue Exception => e
    log :fatal, "#{e.inspect}\n#{e.backtrace}"

    # Internal server error
    500
  end
end

def log level, message
  # verbose
  puts message if settings.verbose

  # logger
  settings.logger.send(level, message) if settings.logger
end

if $test_ais
  at_exit { Berlin::Fake::Game.new($test_ais).run }
else
  set :app_file, $0
end
