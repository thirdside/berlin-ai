module Berlin
  module AI
    # Node will help us to keep track of possible moves.
    # We'll be able to use it in order to know if two
    # nodes are adjacent, how much points worth a node, etc.
    class Node
      attr_accessor :id, :player_id, :number_of_soldiers, :incoming_soldiers, :available_soldiers, :type
      attr_reader   :soldiers_per_turn, :points

      def initialize node, type
        @id                 = node['id']
        @type               = node['type']
        @points             = type['points']
        @soldiers_per_turn  = type['soldiers_per_turn']
        @number_of_soldiers = 0
        @player_id          = nil
        @links              = []
      end

      # Reset information for new turn
      def reset!
        self.incoming_soldiers  = 0
        self.available_soldiers = self.number_of_soldiers
      end
      
      # Somewhat useful
      def to_i
        @id.to_i
      end

      # Used to compare if two nodes are the same
      def ==(other)
        other.id == @id
      end

      # Registers a given node as an adjacent one.
      def link_to(other_node)
        @links << other_node
      end

      # Returns true if other_node is adjacent to self
      def adjacent?(other_node)
        @links.include? other_node
      end
      
      # Returns true if self has more than zero soldier
      def occupied?
        @number_of_soldiers > 0
      end

      # Returns true if owned by any player
      def owned?
        !!@player_id
      end

      # Returns true if no one on the node
      def free?
        !owned?
      end
      
      # Returns true if node owned by provided player id
      def owned_by?(player_id)
        @player_id == player_id
      end

      # Returns a list of all adjacent nodes
      def adjacent_nodes
        @links.dup
      end
      
      # Returns a list of all adjacent nodes, plus self
      def adjacent_nodes_and_self
        adjacent_nodes.push( self )
      end
    end
  end
end
