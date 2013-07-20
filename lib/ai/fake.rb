module Berlin
  module Fake

    MAP_DEFINITION = {
      "types" => [
        {"name" => "node", "points" => 0, "soldiers_per_turn" => 0},
        {"name" => "city", "points" => 1, "soldiers_per_turn" => 1}
      ],

      "nodes" => [
        {"id" => 1, "type" => "city"},
        {"id" => 2, "type" => "node"},
        {"id" => 3, "type" => "city"},
        {"id" => 4, "type" => "node"},
        {"id" => 5, "type" => "node"},
        {"id" => 6, "type" => "city"},
        {"id" => 7, "type" => "node"},
        {"id" => 8, "type" => "city"}
      ],

      "paths" => [
        {"from" => 1, "to" => 2},
        {"from" => 2, "to" => 3},
        {"from" => 2, "to" => 5},
        {"from" => 3, "to" => 5},
        {"from" => 5, "to" => 8},
        {"from" => 8, "to" => 7},
        {"from" => 7, "to" => 4},
        {"from" => 6, "to" => 7},
        {"from" => 6, "to" => 4},
        {"from" => 4, "to" => 1},
      ]
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

    GAME_STATE = [
      {"node_id" => 1, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 2, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 3, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 4, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 5, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 6, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 7, "player_id" => nil, "number_of_soldiers" => 0},
      {"node_id" => 8, "player_id" => nil, "number_of_soldiers" => 0}
    ]

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
            game.add_move(node.id, adj.id, num)
            soldiers -= num
          end
        end
      end
    end

    class State
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
          errors << "Trying to move #{move.number_of_soldiers} soldiers from ##{move.from}. Node ##{move.from} belongs to #{origin.player_id}"
        elsif origin.number_of_soldiers < move.number_of_soldiers
          errors << "Trying to move #{move.number_of_soldiers} soldiers from ##{move.from}. Only #{origin.number_of_soldiers} soldiers available"
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

  def initialize(number_of_ai)
    @turn = 0

    @city_nodes = Berlin::Fake::MAP_DEFINITION['nodes'].select{ |node| node['type'] == 'city' }.map{ |node| node['id'] }
    @ai_games = 1.upto(number_of_ai).map do |n|
      ai_name = "AI ##{n}"
      node = Berlin::Fake::GAME_STATE.detect{ |node| node['node_id'] == @city_nodes[n - 1] }
      node['player_id'] = ai_name
      node['number_of_soldiers'] = 5
      ai_info = Berlin::Fake::GAME_INFO.dup
      ai_info['player_id']  = ai_name
      ai_info['game_id']    = n

      Berlin::AI::Game.new(ai_info['game_id'], Berlin::Fake::MAP_DEFINITION, ai_info)
    end

    player_name = "Player"
    player_info = Berlin::Fake::GAME_INFO.dup
    player_info['player_id']  = player_name
    player_info['game_id']    = 0
    node = Berlin::Fake::GAME_STATE.detect{ |node| node['node_id'] == @city_nodes[number_of_ai] }
    node['player_id'] = player_name
    node['number_of_soldiers'] = 5

    @player_game = Berlin::AI::Game.new(player_info['game_id'], Berlin::Fake::MAP_DEFINITION, player_info)

    @state = Berlin::Fake::State.new(Berlin::Fake::GAME_STATE.dup)
  end

  def run
    while !@state.winner? && @turn < Berlin::Fake::GAME_INFO['maximum_number_of_turns']
      turn
      puts "Press any key"
      gets
    end
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
    info = {'current_turn' => @turn}

    @ai_games.each do |game|
      game.clear_moves
      game.update(info, @state.as_json)
      Berlin::Fake::Random.on_turn(game)
    end

    @player_game.update(info, @state.as_json)
    @player_game.clear_moves
    Berlin::AI::Player.on_turn(@player_game)
  end
end
