module Berlin
  module AI
    class Node
      module Internal
        module ClassMethods
          def parse(data)
            node = Node.new

            node.id                 = data['id']
            node.type               = data['type']
            node.points             = data['points']
            node.soldiers_per_turn  = data['soldiers_per_turn']

            node
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        def initialize(options={})
          @number_of_soldiers = 0
          @player_id          = nil
          @links              = []

          options.each do |k,v|
            self.send("#{k}=", v)
          end
        end

        def to_s
          "<Berlin::AI::Node @id=#{@id} @type=#{@type} @points=#{@points} @soldiers_per_turn=#{@soldiers_per_turn} @adjacent_nodes=#{adjacent_nodes.map(&:id)}>"
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
      end
    end
  end
end