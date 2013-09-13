# Berlin-Ai

Berlin-Ai is a gem to quickly ramp up on the [Berlin](http://www.berlin-ai.com) game.

## Usage

Create your AI in a simple `.rb` file:

```ruby
require 'berlin-ai'         # Require the berlin-ai library.

class Berlin::AI::Player
  def self.on_turn(game)         # Implement the on_turn method of Berlin::AI::Player.
    # Do your magic here.

    # Here's an AI that randomly moves soldiers from node to node.
    game.map.controlled_nodes.each do |node|
      node.adjacent_nodes.shuffle.each do |other_node|
        soldiers = rand(0..(node.available_soldiers))
        game.add_move(node, other_node, soldiers)
      end
    end
  end
end
```

You're now ready to host your AI locally or with [Heroku](https://devcenter.heroku.com/articles/rack). We use [Sinatra](http://www.sinatrarb.com) in this gem, so a simple `ruby your_ai_file.rb` will launch the web server.

To modify some defaults, you can execute `ruby your_ai_file.rb -h` for a list of available options.

## API

### game (Berlin::AI::Game)

Entry point in the API from `Berlin::AI::Player#on_turn`.

```ruby
# General information on the game.
game.id                      # This game unique id.
game.number_of_players       # Number of players in this game.
game.maximum_number_of_turns # Maximum number of turns for this game.
game.player_id               # Your player id for this game.
game.time_limit_per_turn     # Maximum number of time (ms) to make your moves, per turn.

# Information on the current turn.
game.current_turn            # The current turn count.
game.turns_left              # Remaining turns before the end of the game.

# Add a move to perform this turn by your AI.
# IMPORTANT: 'from' and 'to' must be node objects.
game.add_move(from, to, number_of_soldiers)

# List of moves to perform this turn by your AI.
game.moves # => [{ from: node_id, to: node_id, number_of_soldiers: int }]

# The game's map with its own set of useful methods.
game.map
```

### map (Berlin::AI::Map)

Helper methods to work with nodes.

```ruby
map.directed?          # Determine if a path from A to B is A -> B (directed) or A <-> B (not directed)
map.nodes              # All the nodes.
map.owned_nodes        # Owned nodes, including those with 0 soldiers.
map.enemy_nodes        # Enemy nodes.
map.free_nodes         # Nodes not controlled by anyone.
map.foreign_nodes      # Nodes not owned (i.e. enemy nodes and free nodes).
map.controlled_nodes   # Owned nodes, excluding those with 0 soldiers.
```

### node (Berlin::AI::Node)

Node objects obtained when querying the map.

```ruby
node.id                       # Id of the node.
node.type                     # Type of node.
node.player_id                # Owner of the node.
node.number_of_soldiers       # Number of soldiers on the node.
node.incoming_soldiers        # Owned soldiers coming to this node (result from add_move calls).
node.available_soldiers       # Owned remaining soldiers on this node (result from add_move calls).
node.==(other)                # Check if two nodes are the same.
node.adjacent?(other_node)    # Check if two nodes are adjacents.
node.occupied?                # Check if some soldiers are on the node.
node.owned?                   # Check if you own the node.
node.free?                    # Check if no one own the node.
node.owned_by?(player_id)     # Check if the node is owned by a given player.
node.adjacent_nodes           # Get a list of adjacent nodes.
node.adjacent_nodes_and_self  # Get a list of adjacent nodes, including this node.
node.soldiers_per_turn        # Spawned soldiers per turn if you own this node.
node.points                   # Given points by this node at the end of the game.
```

## Installation

Add this line to your application's Gemfile:

    gem 'berlin-ai'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install berlin-ai

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
