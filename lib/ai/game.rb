module Berlin
  module AI
    # Game keeps track of current games played by the server, indexing them on their uniq id.
    class Game
      attr_reader :id, :map, :moves, :player_id, :current_turn, :number_of_players, :time_limit_per_turn
      
      # Keep track of all current games
      @@games = {}
      
      def self.create_or_update action, infos, map, state
        # Check for params and quit on errors
        return if action.nil? || infos.nil? || map.nil? || state.nil?
        
        # First, we parse the received request
        infos  = JSON.parse( infos )
        map    = JSON.parse( map )
        state  = JSON.parse( state )

        # Game id, set with player_id as well so an AI can fight with himself
        game_id = "#{infos['game_id']}-#{infos['player_id']}"
        
        # Keep track of the player moves
        @moves = []
        
        # Then, let's see if we can find that game. If not, register it.
        if action == "ping"
          game = Berlin::AI::Game.new game_id, map, infos
        else
          game = (@@games[game_id] ||= Berlin::AI::Game.new( game_id, map, infos ))
        end

        if action == "game_over"
          # Release the game to avoid memory leaks
          @@games.delete game_id
        elsif state
          # Now, we want to update the current state of the game with the new content
          game.update state
        end

        game
      end
      
      def initialize id, map, infos
        @id  = id
        
        # Extract usefull informations
        @player_id = infos['player_id']
        @time_limit_per_turn = infos['time_limit_per_turn']
        @current_turn = infos['current_turn'].to_i
        @maximum_number_of_turns = infos['maximum_number_of_turns'].to_i
        @number_of_players = infos['number_of_players']
        
        # How many turns left?
        @turns_left = @maximum_number_of_turns - @current_turn
        
        # Create the map
        @map = Berlin::AI::Map.new map, infos
      end
      
      def add_move from, to, number_of_soldiers        
        @moves << {:from=>from.to_i, :to=>to.to_i, :number_of_soldiers=>number_of_soldiers.to_i}
      end

      def update state
        @map.update state
      end
    end
  end
end
