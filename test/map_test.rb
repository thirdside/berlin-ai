
require_relative '../lib/ai/node_internal'
require_relative '../lib/ai/node'
require_relative '../lib/ai/map_internal'
require_relative '../lib/ai/map'

require "test/unit"
 
class MapTest < Test::Unit::TestCase

  def setup
    @map = Berlin::AI::Map.new
    @map.player_id = 1

    @node1 = Berlin::AI::Node.new(:id => 1, :map => @map, :player_id => 1, :number_of_soldiers => 0)
    @node2 = Berlin::AI::Node.new(:id => 2, :map => @map, :player_id => 1, :number_of_soldiers => 3)
    @node3 = Berlin::AI::Node.new(:id => 3, :map => @map, :player_id => nil)
    @node4 = Berlin::AI::Node.new(:id => 4, :map => @map, :player_id => 2)
    @node5 = Berlin::AI::Node.new(:id => 5, :map => @map, :player_id => 3)

    @map.nodes_hash = {1 => @node1, 2 => @node2, 3 => @node3, 4 => @node4, 5 => @node5}
  end

  def test_nodes_returns_an_array_of_all_nodes
    assert_equal [@node1, @node2, @node3, @node4, @node5], @map.nodes
  end

  def test_owned_nodes_returns_an_array_of_owned_nodes_for_current_player
    assert_equal [@node1, @node2], @map.owned_nodes
  end

  def test_foreign_nodes_returns_an_array_of_nodes_that_the_current_player_does_not_owned
    assert_equal [@node3, @node4, @node5], @map.foreign_nodes
  end

  def test_enemy_nodes_returns_an_array_of_nodes_owned_by_other_players
    assert_equal [@node4, @node5], @map.enemy_nodes
  end

  def test_free_nodes_returns_an_array_of_free_nodes
    assert_equal [@node3], @map.free_nodes
  end

  def test_controlled_nodes_returns_an_array_of_owned_nodes_with_at_least_one_soldier
    assert_equal [@node2], @map.controlled_nodes
  end

end