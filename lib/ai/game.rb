module Berlin
  module AI
    # Game keeps track of current games played by the server, indexing them on their uniq id.
    class Game
      include Internal

      attr_accessor :id, :map, :moves, :player_id, :current_turn, :number_of_players,
                  :time_limit_per_turn, :maximum_number_of_turns, :turns_left
      
      def add_move(from, to, number_of_soldiers)     
        # remove moving soldiers from from node
        from.available_soldiers -= number_of_soldiers

        # adding incoming soldiers to next node
        to.incoming_soldiers += number_of_soldiers

        # add move
        @moves << {:from => from.to_i, :to => to.to_i, :number_of_soldiers => number_of_soldiers.to_i}
      end

    end
  end
end
