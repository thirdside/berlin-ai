module Berlin
  module AI
    class Map
      module Internal
        def initialize(options={})
          @nodes = {}

          options.each do |k,v|
            self.send("#{k}=", v)
          end
        end

        # Let's update the current state with the latest provided info! With this step,
        # we'll now know who possess the node and how many soldiers there is.
        # state contains an array of nodes, so we just have to loop on it.
        # state => [{:node_id => STRING, :number_of_soldiers => INTEGER, :player_id => INTEGER}, ...]
        def update(state)
          state.each do |n|
            node                    = @nodes[n['node_id']]
            node.number_of_soldiers = n['number_of_soldiers']
            node.player_id          = n['player_id']
          end
        end

        def self.parse(data)
          map = Map.new

          # Node types
          types = data['types'].each.with_object({}) do |type, types|
            types[type['name']] = type
          end
          
          # Let's parse data['nodes'] and register all nodes we can find.
          # We'll keep track of them in @nodes so we can find them later.
          # At this step (Map creation...), we still don't know who possess
          # the node and how many soldiers there is. We'll get back to that later.
          # map['nodes'] => [{:id => STRING}, ...]
          data['nodes'].each do |node|
            @nodes[node['id']] = Berlin::AI::Node.parse(node.merge(types[node['type']]))
          end

          # Same thing here, with paths.
          # map['paths'] => [{:from => INTEGER, :to => INTEGER}, ...]
          data['paths'].each do |path|
            @nodes[path['from']].link_to(@nodes[path['to']])

            # Don't forget! If the map is not directed, we must create the reverse link!
            @nodes[path['to']].link_to(@nodes[path['from']]) unless directed?
          end

          # and... return the newly created map
          map
        end
      end
    end
  end
end