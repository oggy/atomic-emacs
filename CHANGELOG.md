## 0.2.1

* Fixed a bug where the selection can only move in the y-axis.
* Improved set-mark. It will now retain the selection on most of the current motion commands. Still have to figure out how to make this work with ctrl-v and alt-v.
* ctrl-g will now cancel the selection.

## 0.2.0

* Added marks to select an arbitrary group of text. This should be mapped by the user because the core ctrl-space mapping can't be overriden by this package.
* Added transpose characters.
* Added an emacs style copy mapped to alt-w.
* Added alt-; mapping for toggling line comments
* The mark's head and tail can be swapped with ctrl-x ctrl-x.
* Transposing lines now make use of the new transactions API.

## 0.1.1

* Rebound some more keys.
* Ctrl-g will now attempt to cancel an action. Works most of the time except for the editor, because the core Go To Line keymap which can't be overridden it seems.

## 0.1.0

* Initial Release. Lots of things missing.
