module Berlin
  module AI
    # Node will help us to keep track of possible moves.
    # We'll be able to use it in order to know if two
    # nodes are adjacent, how much points worth a node, etc.
    class Node
      attr_accessor :id, :player_id, :number_of_soldiers

      def initialize id
        @id                 = id
        @number_of_soldiers = 0
        @player_id          = 0
        @links              = []
      end

      # Register a given node as an adjacent one.
      def link_to other_node
        @links << other_node
      end

      # Is other_node adjacents to current node?
      def adjacent? other_node
        @links.include? other_node
      end
      
      # Is there anybody out there?
      def occupied?
        @number_of_soldiers > 0
      end

      # What are current node's neighbors?
      def adjacent_nodes
        @links.dup
      end
    end
  end
end
