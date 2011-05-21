require 'rubygems'
require 'berlin-ai'

class Berlin::AI::Game
  def turn_moves
    @map.controlled_nodes.collect do |node|
      {
        :from => node.id,
        :to => node.adjacent_nodes.sample.id,
        :number_of_soldiers => rand(node.number_of_soldiers + 1)
      }
    end
  end
end
