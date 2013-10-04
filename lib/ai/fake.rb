require 'pry'
require 'pry-debugger'
require "net/http"
require "uri"
require 'rainbow'
require 'terminfo'

module Berlin
  module Fake

    CITY_WALL = ["2588".hex].pack("U")
    NODE_WALL = "#"
    PATH      = "."

    MAP_DEFINITION = {
      "types" => [
        {"name" => "city","soldiers_per_turn" => 1,"points" => 1},
        {"name" => "node","soldiers_per_turn" => 0,"points" => 0}
      ],
      "nodes" => [
        {"id" => 1, "type" => "city", "x" => 10, "y" => 10},
        {"id" => 2, "type" => "city", "x" => 30, "y" => 10},
        {"id" => 3, "type" => "city", "x" => 10, "y" => 30},
        {"id" => 4, "type" => "city", "x" => 30, "y" => 30},
        {"id" => 5, "type" => "city", "x" => 90, "y" => 10},
        {"id" => 6, "type" => "city", "x" => 70, "y" => 10},
        {"id" => 7, "type" => "city", "x" => 90, "y" => 30},
        {"id" => 8, "type" => "city", "x" => 70, "y" => 30},
        {"id" => 9, "type" => "city", "x" => 10, "y" => 90},
        {"id" => 10, "type" => "city", "x" => 10, "y" => 70},
        {"id" => 11, "type" => "city", "x" => 30, "y" => 90},
        {"id" => 12, "type" => "city", "x" => 30, "y" => 70},
        {"id" => 13, "type" => "city", "x" => 90, "y" => 90},
        {"id" => 14, "type" => "city", "x" => 70, "y" => 90},
        {"id" => 15, "type" => "city", "x" => 90, "y" => 70},
        {"id" => 16, "type" => "city", "x" => 70, "y" => 70},
        {"id" => 17, "type" => "node", "x" => 25, "y" => 50},
        {"id" => 18, "type" => "node", "x" => 75, "y" => 50},
        {"id" => 19, "type" => "node", "x" => 40, "y" => 50},
        {"id" => 20, "type" => "node", "x" => 60, "y" => 50},
        {"id" => 21, "type" => "node", "x" => 50, "y" => 25},
        {"id" => 22, "type" => "node", "x" => 50, "y" => 75},
        {"id" => 23, "type" => "node", "x" => 50, "y" => 40},
        {"id" => 24, "type" => "node", "x" => 50, "y" => 60}
      ],
      "paths"=> [
        {"from" => 1, "to" => 2},
        {"from" => 1, "to" => 3},
        {"from" => 2, "to" => 3},
        {"from" => 2, "to" => 4},
        {"from" => 3, "to" => 4},
        {"from" => 5, "to" => 6},
        {"from" => 5, "to" => 7},
        {"from" => 6, "to" => 7},
        {"from" => 6, "to" => 8},
        {"from" => 7, "to" => 8},
        {"from" => 9, "to" => 10},
        {"from" => 9, "to" => 11},
        {"from" => 10, "to" => 11},
        {"from" => 10, "to" => 12},
        {"from" => 11, "to" => 12},
        {"from" => 13, "to" => 14},
        {"from" => 13, "to" => 15},
        {"from" => 14, "to" => 15},
        {"from" => 14, "to" => 16},
        {"from" => 15, "to" => 16},
        {"from" => 4, "to" => 19},
        {"from" => 4, "to" => 23},
        {"from" => 8, "to" => 20},
        {"from" => 8, "to" => 23},
        {"from" => 12, "to" => 19},
        {"from" => 12, "to" => 24},
        {"from" => 16, "to" => 24},
        {"from" => 16, "to" => 20},
        {"from" => 17, "to" => 19},
        {"from" => 18, "to" => 20},
        {"from" => 21, "to" => 23},
        {"from" => 22, "to" => 24},
        {"from" => 3, "to" => 17},
        {"from" => 10, "to" => 17},
        {"from" => 7, "to" => 18},
        {"from" => 15, "to" => 18},
        {"from" => 6, "to" => 21},
        {"from" => 2, "to" => 21},
        {"from" => 11, "to" => 22},
        {"from" => 14, "to" => 22}
      ],
      "setup" => {
        "2" => {
          "0" => [{"node" => 1,"number_of_soldiers" => 5}],
          "1" => [{"node" => 13,"number_of_soldiers" => 5}]
        },
        "4" => {
          "0" => [{"node" => 1,"number_of_soldiers" => 5}],
          "1" => [{"node" => 5, "number_of_soldiers" => 5}],
          "2" => [{"node" => 9, "number_of_soldiers" => 5}],
          "3" => [{"node" => 13, "number_of_soldiers" => 5}]
        }
      }
    }

    GAME_INFO = {
      "game_id"                 => "7c7905c6-2423-4a91-b5e7-44ff10cddd5d",
      "current_turn"            => nil,
      "maximum_number_of_turns" => 1000,
      "number_of_players"       => 2,
      "time_limit_per_turn"     => 5000,
      "directed"                => false,
      "player_id"               => nil
    }


    Move = Struct.new(:player_id, :from, :to, :number_of_soldiers)

    NodeState = Struct.new(:node_id, :player_id, :number_of_soldiers)

    ConflictState = Struct.new(:node_id, :soldiers_per_player) do
      def initialize(node_id)
        super(node_id)
        self.soldiers_per_player = Hash.new(0)
      end

      def add_soldiers(player_id, number_of_soldiers)
        self.soldiers_per_player[player_id] += number_of_soldiers
      end

      def process(node)
        add_soldiers(node.player_id, node.number_of_soldiers) if node.player_id

        puts "[Conflict] Resolving conflicts for ##{node.node_id}"

        losses = soldiers_per_player.values.sort.reverse[1] || 0

        soldiers_per_player.each do |player_id, number_of_soldiers|
          if number_of_soldiers < losses || number_of_soldiers == losses && node.player_id != player_id
            puts "\t[#{player_id}] loses #{number_of_soldiers} soldiers"
          else
            node.number_of_soldiers = number_of_soldiers - losses
            puts "\t[#{player_id}] wins the combat with #{number_of_soldiers - losses} soldiers left"
            node.player_id = player_id
          end
        end
      end
    end

    class Random
      def self.on_turn(game)
        game.map.controlled_nodes.each do |node|
          soldiers = node.number_of_soldiers

          node.adjacent_nodes.each do |adj|
            num = rand(0...soldiers)
            game.add_move(node, adj, num)
            soldiers -= num
          end
        end
      end
    end

    class Display

      COLORS = [:red, :green, :yellow, :blue]

      Position = Struct.new(:x, :y)

      def initialize(map_definition, state)
        @map_definition = map_definition
        @state = state.state
        @player_ids = @state.map{ |id, n| n['player_id'] }.uniq.compact.sort

        @height, @width = TermInfo.screen_size
        @height -= @player_ids.length + 1
        @map = 1.upto(@height).map { [" "] * @width }
      end

      def color(player_id)
        player_id.nil? ? :white : COLORS[@player_ids.index(player_id)]
      end

      def as_display
        paths_as_display
        nodes_as_display
        map = @map.map{ |a| a.join '' }.join("\n")
        [map, *@player_ids.map{ |id| id.to_s.foreground(color(id)) }].join("\n")
      end

      def paths_as_display
        @map_definition['paths'].each do |path|
          from_node = @map_definition['nodes'][path['from']-1]
          to_node = @map_definition['nodes'][path['to']-1]

          from = node_position(from_node)
          to = node_position(to_node)

          draw_line(from, to)
        end
      end

      def draw_line(from, to)
        xs = range(from[0], to[0])
        ys = range(from[1], to[1])

        length = [xs.length, ys.length].max

        (0...length).each do |n|
          x = xs[(n.to_f/length * xs.length).floor]
          y = ys[(n.to_f/length * ys.length).floor]

          replace(x, y, PATH)
        end
      end

      def range(from, to)
        from > to ? (to..from).to_a.reverse : (from..to).to_a
      end

      def node_position(node)
        x = (node['x'] / 100.0 * @width).to_i
        y = (node['y'] / 100.0 * @height).to_i
        [x, y]
      end

      def nodes_as_display
        # ID###
        # # 12#
        # V###S
        @map_definition['nodes'].each do |node|
          node_state = @state[node['id']]

          x, y = node_position(node)

          player_color = color(node_state.player_id)

          meta = @map_definition['types'].detect{|n| n['name'] == node['type']}
          value = meta['soldiers_per_turn'] + meta['points']

          wall = value > 0 ? CITY_WALL : NODE_WALL
          (-1..1).each do |n|
            replace(x-2, y+n, wall*5, player_color)
          end

          replace(x-2, y-1, node['id'])
          number_of_soldiers = node_state.number_of_soldiers.to_s.center(3)
          replace(x-1, y, number_of_soldiers, player_color)

          if value > 0
            soldiers_per_turn = meta['soldiers_per_turn'].to_s
            replace(x-2, y+1, meta['points'])
            replace(x+2, y+2 - soldiers_per_turn.length, soldiers_per_turn)
          end
        end
      end

      def replace(x, y, str, foreground = nil)
        length = str.to_s.size
        (0...length).each do |n|
          char = str.to_s[n]
          @map[y][x+n] = foreground ? char.foreground(foreground) : char
        end
      end
    end

    class State
      attr_accessor :state
      def initialize(from_json)
        @state = from_json.inject({}) do |h, node|
          h[node['node_id']] = NodeState.new(node['node_id'], node['player_id'], node['number_of_soldiers'])
          h
        end
      end

      def apply_moves(moves)
        conflicts = {}
        errors    = []
        puts "[Moves]"
        moves.each do |move|
          conflict = (conflicts[move.to] ||= ConflictState.new(move.to))
          remove_soldiers(move)
          conflict.add_soldiers(move.player_id, move.number_of_soldiers)
        end

        conflicts.each { |node_id, conflict| conflict.process(@state[node_id]) }
      end

      def remove_soldiers(move)
        origin = @state[move.from]
        if origin.player_id != move.player_id
          puts  "Trying to move #{move.number_of_soldiers} soldiers from ##{move.from}. Node ##{move.from} belongs to #{origin.player_id}"
        elsif origin.number_of_soldiers < move.number_of_soldiers
          puts "Trying to move #{move.number_of_soldiers} soldiers from ##{move.from}. Only #{origin.number_of_soldiers} soldiers available"
        else
          origin.number_of_soldiers -= move.number_of_soldiers
          puts "\t[#{move.player_id}] Moves #{move.number_of_soldiers} soldiers from ##{move.from} to ##{move.to}"
        end
      end

      def spawn(node_ids)
        node_ids.each { |id| @state[id].number_of_soldiers += 1 if @state[id].player_id }
      end

      def as_json
        @state.map do |node_id, node_state|
          {
            'node_id'             => node_state.node_id,
            'player_id'           => node_state.player_id,
            'number_of_soldiers'  => node_state.number_of_soldiers
          }
        end
      end

      def inspect
        as_json
      end

      def winner?
        @state.map{ |node_id, node_state| node_state.player_id }.compact.length == 1
      end
    end
  end
end

class Berlin::Fake::Game

  def initialize(options)
    @options = options
    number_of_ai    = options[:test_ais]
    @turn           = 0
    map_definition
    @game_info      = Berlin::Fake::GAME_INFO

    @game_state = @map_definition['nodes'].map do |node|
      {"node_id" => node['id'], "player_id" => nil, "number_of_soldiers" => 0}
    end

    @state = Berlin::Fake::State.new(@game_state.dup)

    @city_nodes = @map_definition['nodes'].select{ |node| node['type'] == 'city' }.map{ |node| node['id'] }

    start_points = @map_definition['setup'][(number_of_ai + 1).to_s]

    unless start_points
      puts("This map cannot be played with #{number_of_ai+1} players. #{@map_definition['setup'].keys.join(', ')} are possible only")
      exit
    end

    players = 1.upto(number_of_ai).map{ |n| "AI ##{n}" } << "Player"

    @ai_games = players.each.with_index.map do |name, index|
      start_points[index.to_s].each do |point|
        node = @state.state[point['node']]

        node['player_id'] = name
        node['number_of_soldiers'] = point['number_of_soldiers']
      end
      ai_info = @game_info.dup
      ai_info['player_id'] = name
      ai_info['game_id'] = index

      map = Berlin::AI::Map.parse(@map_definition.dup.merge('player_id' => ai_info['player_id']))
      game = Berlin::AI::Game.new
      game.map                      = map
      game.id                       = ai_info['game_id']
      game.player_id                = ai_info['player_id']
      game.time_limit_per_turn      = ai_info['time_limit_per_turn']
      game.maximum_number_of_turns  = ai_info['maximum_number_of_turns']
      game.number_of_players        = ai_info['number_of_players']
      game.reset!

      game
    end

    @player_game = @ai_games.pop
  end

  def map_definition
    return @map_definition if @map_definition
    if @options[:map_id]
      uri = URI.parse("http://berlin-ai.com/maps/#{@options[:map_id]}.json")
      response = Net::HTTP.get_response(uri)
      begin
        @map_definition = JSON(response.body).fetch('map').fetch('representation')
      rescue => e
        puts "There was a problem downloading the map #{@options[:map_id]}"
        puts e.message
        exit
      end
    else
      @map_definition = Berlin::Fake::MAP_DEFINITION
    end
  end

  def run
    puts Berlin::Fake::Display.new(@map_definition, @state).as_display
    pause
    while !@state.winner? && @turn < Berlin::Fake::GAME_INFO['maximum_number_of_turns']
      turn
      pause
      puts Berlin::Fake::Display.new(@map_definition, @state).as_display
      pause
    end
  end

  def pause
    puts "Press any key to continue"
    gets
  end

  def turn
    @turn += 1
    generate_moves
    player_moves = buffer_moves

    @state.apply_moves(player_moves.values.flatten)

    spawn
  end

  def spawn
    @state.spawn(@city_nodes)
  end

  def buffer_moves
    moves = {}
    [@player_game, *@ai_games].each do |game|
      player_moves = {}

      game.moves.each do |move|
        move[:player_id] = game.player_id
        ref = "#{move[:from]}_#{move[:to]}"
        player_moves[ref] ||= Berlin::Fake::Move.new(game.player_id, move[:from], move[:to], 0)
        player_moves[ref].number_of_soldiers += move[:number_of_soldiers]
      end
      moves[game.player_id] = player_moves.values
    end
    moves
  end

  def generate_moves
    @ai_games.each do |game|
      game.reset!
      game.update(@turn, @state.as_json)
      Berlin::Fake::Random.on_turn(game)
    end

    @player_game.update(@turn, @state.as_json)
    @player_game.reset!
    Berlin::AI::Player.on_turn(@player_game)
  end
end
