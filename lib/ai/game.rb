module Berlin
  module AI
    # Game keeps track of current games played by the server, indexing them on their uniq id.
    class Game
      attr_reader :id, :map, :moves, :player_id, :current_turn, :number_of_players, :time_limit_per_turn, :maximum_number_of_turns, :turns_left
      
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
        
        # Then, let's see if we can find that game. If not, register it.
        if action == "ping"
          game = Berlin::AI::Game.new game_id, map, infos
        else
          game = (@@games[game_id] ||= Berlin::AI::Game.new( game_id, map, infos ))
        end
        
        if action == "game_over"
          # Release the game to avoid memory leaks
          @@games.delete game_id
        elsif infos && state
          # Now, we want to update the current state of the game with the new content, as well as other infos
          game.update infos, state
        end

        game
      end
      
      def initialize id, map, infos
        @id  = id
        
        # Extract usefull static informations
        @player_id                = infos['player_id']
        @time_limit_per_turn      = infos['time_limit_per_turn']
        @maximum_number_of_turns  = infos['maximum_number_of_turns'].to_i
        @number_of_players        = infos['number_of_players']
        
        # Create the map
        @map = Berlin::AI::Map.new map, infos
      end
      
      def add_move from, to, number_of_soldiers        
         # remove moving soldiers from from node
        from.available_soldiers -= number_of_soldiers

        # adding incoming soldiers to next node
        to.incoming_soldiers += number_of_soldiers

        # add move
        @moves << {:from => from.to_i, :to => to.to_i, :number_of_soldiers => number_of_soldiers.to_i}
      end

      def update infos, state
        # Update turn infos
        @current_turn = infos['current_turn'].to_i
        @turns_left   = @maximum_number_of_turns - @current_turn
        
        # Update map state
        @map.update state
      end
      
      def reset!
        @moves = []
        @map.nodes.each(&:reset!)
      end
    end
  end
end
