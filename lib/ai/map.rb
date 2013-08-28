module Berlin
  module AI
    # Map keeps track of all the useful information needed to play, such as
    # nodes, points, soldiers, etc. Game will then be able to pick any information
    # it wants from map to decide what are the best moves to do.
    class Map
      def initialize map, infos
        @player_id  = infos['player_id']
        @nodes      = {}
        @types      = {}
        @directed   = infos['directed'] || false
        
        # Node types
        map['types'].each do |type|
          @types[type['name']] = type
        end
        
        # Let's parse map['nodes'] and register all nodes we can find.
        # We'll keep track of them in @nodes so we can find them later.
        # At this step (Map creation...), we still don't know who possess
        # the node and how many soldiers there is. We'll get back to that later.
        # map['nodes'] => [{:id => STRING}, ...]
        map['nodes'].each do |node|
          @nodes[node['id']] = Berlin::AI::Node.new node, @types[node['type']]
        end

        # Same thing here, with paths.
        # map['paths'] => [{:from => INTEGER, :to => INTEGER}, ...]
        map['paths'].each do |path|
          @nodes[path['from']].link_to @nodes[path['to']]

          # Don't forget! If the map is not directed, we must create the reverse link!
          @nodes[path['to']].link_to @nodes[path['from']] unless directed?
        end
      end
      
      # Returns an array of all nodes of the map
      def nodes
        @nodes.values
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

      # Let's update the current state with the latest provided info! With this step,
      # we'll now know who possess the node and how many soldiers there is.
      # state contains an array of nodes, so we just have to loop on it.
      # state => [{:node_id => STRING, :number_of_soldiers => INTEGER, :player_id => INTEGER}, ...]
      def update state
        state.each do |n|
          node                    = @nodes[n['node_id']]
          node.number_of_soldiers = n['number_of_soldiers']
          node.player_id          = n['player_id']
        end
      end
    end
  end
end
