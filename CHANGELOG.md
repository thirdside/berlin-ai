# Changelog

#### Version 0.38

*Only few changes in this version. `node.owned?` was change to be more in line with `map.owned_nodes`, plus a few bug fixes.*

* `node.owned?` used to return true if owned by any player. It's now an alias of `node.mine?`, which return true if you personnaly own the node.
* `node.foreign?` has been added. Returns true if you don't own the node.
* Creation of this file, CHANGELOG.
* Few bug fixes.

#### Version 0.37

*Few helper methods. Nothing more.*

* `node.enemy?` has been added. Returns true if owned by another player.
* Few bug fixes.