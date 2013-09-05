require_relative '../lib/ai/node_internal'
require_relative '../lib/ai/node'

require "test/unit"
 
class NodeTest < Test::Unit::TestCase
 
  def test_equals_returns_true_if_two_nodes_have_the_same_id
    node1 = Berlin::AI::Node.new(:id => 1)
    node2 = Berlin::AI::Node.new(:id => 2)

    assert node1 != node2

    node2.id = 1

    assert node1 == node2
  end

  def test_reset_resets_all_turn_relative_data
    node = Berlin::AI::Node.new(:number_of_soldiers => 2, :incoming_soldiers => 3, :available_soldiers => 4)
    node.reset!
    assert_equal 0, node.incoming_soldiers
    assert_equal node.number_of_soldiers, node.available_soldiers
  end

  def test_adjacent_returns_weither_or_not_a_node_is_adjacent
    node1 = Berlin::AI::Node.new(:id => 1)
    node2 = Berlin::AI::Node.new(:id => 2)
    node3 = Berlin::AI::Node.new(:id => 3)

    node1.link_to(node2)

    assert node1.adjacent?(node2)
    assert !node1.adjacent?(node3)
  end

  def test_occupied_returns_true_if_the_node_has_at_least_one_soldiers
    node = Berlin::AI::Node.new

    assert !node.occupied?

    node.number_of_soldiers = 10

    assert node.occupied?
  end

  def test_free_returns_true_if_the_node_is_not_owned_by_any_player
    node = Berlin::AI::Node.new

    assert node.free?

    node.player_id = 1

    assert !node.free?
  end

  def test_owned_by_returns_true_if_owned_by_the_provided_player
    node = Berlin::AI::Node.new

    assert !node.owned_by?(1)

    node.player_id = 1

    assert node.owned_by?(1)
  end

  def test_owned_returns_true_if_owned_by_a_player
    node = Berlin::AI::Node.new

    assert !node.owned?

    node.player_id = 1

    assert node.owned?
  end
 
end