
require_relative '../lib/ai/node_internal'
require_relative '../lib/ai/node'
require_relative '../lib/ai/map_internal'
require_relative '../lib/ai/map'

require 'pry'
require "test/unit"
 
class MapTest < Test::Unit::TestCase

  def setup
    @node1 = Berlin::AI::Node.new(:id => 1, :player_id => 1)
    @node2 = Berlin::AI::Node.new(:id => 2, :player_id => 1)
    @node3 = Berlin::AI::Node.new(:id => 3, :player_id => nil)
    @node4 = Berlin::AI::Node.new(:id => 4, :player_id => 2)
    @node5 = Berlin::AI::Node.new(:id => 5, :player_id => 3)

    @map = Berlin::AI::Map.new
    @map.player_id = 1
    @map.nodes = {1 => @node1, 2 => @node2, 3 => @node3, 4 => @node4, 5 => @node5}
  end

  def test_nodes_returns_an_array_of_all_nodes
    assert_equal [@node1, @node2, @node3, @node4, @node5], @map.nodes
  end

  def test_owned_nodes_returns_an_array_of_owned_nodes_for_current_player
    assert_equal [@node1, @node2], @map.owned_nodes
  end

  def test_foreign_nodes_returns_and_array_of_nodes_that_the_current_player_does_not_owned
    assert_equal [@node3, @node4, @node5], @map.foreign_nodes
  end

end