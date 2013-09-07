require 'optparse'
require 'sinatra'
require 'logger'
require 'yajl/json_gem'

puts " __                  __ __             _______ _______ "
puts "|  |--..-----..----.|  |__|.-----.    |   _   |_     _|"
puts "|  _  ||  -__||   _||  |  ||     |    |       |_|   |_ "
puts "|_____||_____||__|  |__|__||__|__|    |___|___|_______|"
puts

%w(game_internal game map_internal map node_internal node fake standalone).each do |file|
  require File.expand_path(File.dirname( __FILE__ )) + "/ai/#{file}"
end

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

    set :logger, Logger.new( l || 'berlin.log' )
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

module Berlin
  module AI
    class << self
      attr_accessor :handler
    end

    def self.included(base)
      base.send :attr_accessor, :game
      base.send :attr_accessor, :map
      self.handler = base
    end
  end
end

if $test_ais
  at_exit { Berlin::Fake::Game.new($test_ais).run }
else
  at_exit { Berlin::Standalone.run! }
end

