require 'rubygems'
require 'sinatra'
require 'yajl/json_gem'
require 'berlin-ai'

module Berlin
  module AI
    class Game
      def turn_moves
        @map.controlled_nodes.map do |node|
          {
            :from => node.id,
            :to => node.adjacent_nodes.sample.id,
            :number_of_soldiers => rand(node.number_of_soldiers + 1)
          }
        end
      end
    end
  end
end
