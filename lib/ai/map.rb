module Berlin
  module AI
    # Map keeps track of all the useful information needed to play, such as
    # nodes, points, soldiers, etc. Game will then be able to pick any information
    # it wants from map to decide what are the best moves to do.
    class Map
      include Internal

      attr_accessor :player_id, :nodes_hash, :directed
      
      # Returns an array of all nodes of the map
      def nodes
        @nodes_hash.values
      end

      # Returns an array of all owned nodes
      def owned_nodes
        nodes.select do |node|
          node.owned_by?(@player_id)
        end
      end

      # Returns an array of all enemy nodes
      def enemy_nodes
        nodes.select do |node|
          node.owned? && !owned_by?(@player_id)
        end
      end

      # Returns an array of all free nodes
      def free_nodes
        nodes.select do |node|
          node.free?
        end
      end

      # Returns an array of all nodes that we don't owned
      def foreign_nodes
        nodes.reject do |node|
          node.owned_by?(@player_id)
        end
      end

      # We can now loop on our owned nodes in order to find our controlled nodes.
      def controlled_nodes
        owned_nodes.select do |node|
          node.occupied?
        end
      end

      # Is the map directed?
      def directed?
        @directed
      end
    end
  end
end
