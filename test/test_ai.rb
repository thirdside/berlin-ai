require 'rubygems'
require 'berlin-ai'

class Berlin::AI::Player
  def self.on_turn( game )
    
    
    game.add_move( 1, 2, 12 )
  end
end
