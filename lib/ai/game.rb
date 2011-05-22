module Berlin
  module AI
    # Game keeps track of current games played by the server, indexing them on their uniq id.
    class Game
      attr_reader :id, :map
      
      # Keep track of all current games
      @@games = {}
      
      def self.create_or_update action, infos, map, state
        # Check for params and quit on errors
        return if action.nil? || infos.nil? || map.nil? || state.nil?
        
        # First, we parse the received request
        infos  = JSON.parse( infos )
        map    = JSON.parse( map )
        state  = JSON.parse( state )

        # Game id
        game_id = infos['game_id']
        
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
        @map = Berlin::AI::Map.new map, infos
      end

      def update state
        @map.update state
      end
      
      # This method must be overritten with yours. The return value of this method will be returned
      # in a json format to Berlin and be interpreted as the moves you'd like to do.
      def turn_moves
        raise "Please... overwrite me!"
      end
    end
  end
end
