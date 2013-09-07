# Berlin-Ai

Berlin-Ai is a gem to quickly rampup on the [Berlin](http://www.berlin-ai.com) game

## Usage

To create you AI, simply extend `Berlin::AI::Player` and implement the `self.on_turn` method.

```
class Berlin::AI::Player
  def on_turn(game)
    # Do the magic here

    # Here's an AI that randomly moves soldiers from node to node
    game.map.controlled_nodes.each do |node|
      node.adjacent_nodes.shuffle.each do |other_node|
        rand(0..(node.available_soldiers))
        game.add_move(node.id, other_node.id, soldiers)
      end
    end
  end
end
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
