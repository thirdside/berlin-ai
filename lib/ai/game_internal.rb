module Berlin
  module AI
    class Game
      module Internal
        module ClassMethods
          # Keep track of all current games
          @@games = {}

          def create_or_update(action, infos, map, state)
            # Check for params and quit on errors
            return if action.nil? || infos.nil? || map.nil? || state.nil?

            # First, we parse the received request
            infos  = JSON.parse( infos )
            map    = JSON.parse( map )
            state  = JSON.parse( state )

            # Game id, set with player_id as well so an AI can fight with himself
            game_id = "#{infos['game_id']}-#{infos['player_id']}"

            # Then, let's see if we can find that game. If not, register it.
            game = @@games[game_id] ||= begin
              game                          = Berlin::AI::Game.new
              game.id                       = game_id
              game.map                      = Berlin::AI::Map.parse(map.merge!(infos.select{ |k,v| ['directed', 'player_id'].include?(k) }))
              game.player_id                = infos['player_id']
              game.time_limit_per_turn      = infos['time_limit_per_turn']
              game.maximum_number_of_turns  = infos['maximum_number_of_turns']
              game.number_of_players        = infos['number_of_players']
              game
            end

            if action == "game_over"
              # Release the game to avoid memory leaks
              @@games.delete(game_id)
            elsif infos && state
              # Now, we want to update the current state of the game with the new content, as well as other infos
              game.update(infos['current_turn'], state)
            end

            game
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        def update(current_turn, state)
          # Update turn infos
          @current_turn = current_turn.to_i
          @turns_left   = @maximum_number_of_turns - @current_turn
          
          # Update map state
          @map.update(state)
        end
        
        def reset!
          @moves = []
          @map.nodes.each(&:reset!)
        end
      end
    end
  end
end