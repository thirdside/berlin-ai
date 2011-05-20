module Berlin
  module AI
    class Game
      attr_reader :id
      
      @@games = {}
      
      def self.create_or_update action, infos, map, state
        # Check for params and quit on errors
        return nil if action.nil? || infos.nil? || map.nil? || state.nil?
        
        # First, we parse the received request
        infos  = JSON.parse( infos )
        map    = JSON.parse( map )
        state  = JSON.parse( state )

        # Then, let's see if we can find that game. If not, register it.
        game_id = infos['game_id']
        @@games[game_id] ||= Berlin::AI::Game.new game_id, map, infos
        game = @@games[game_id]

        if action == "game_over"
          # Release the game to avoid memory leaks
          @@games[game_id] = nil
        elsif state
          # Now, we want to update the current state of the game with the new content
          game.update state
        end

        game
      end
      
      # @id = Uniq game ID (params[:game])
      # @map = Current state of the game (params[:json])
      def initialize id, map, infos
        @id         = id
        @map        = Berlin::AI::Map.new map, infos
      end

      # Let's update the map with the latest state
      def update state
        @map.update state
      end
      
      # Must be overwritten
      def turn_moves
        raise "Please... overwrite me!"
      end
    end
  end
end
