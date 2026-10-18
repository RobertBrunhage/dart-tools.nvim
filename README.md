# Installation

using `vim-plug`

```vim
Plug 'robertbrunhage/dart-tools.nvim'
```

using `packer.nvim`

```lua
use {'robertbrunhage/dart-tools.nvim'}
```

using `lazy.nvim`

```lua
'robertbrunhage/dart-tools.nvim'
```

Then load it somewhere in your config:

```lua
require("dart-tools")
```

## Hot reload

Run `flutter run` (or `flutter attach`) in any terminal, no extra flags needed.
Saving a `.dart` file in Neovim hot reloads every running app.

Saves while an app is still starting are ignored. Flutter only listens for the
reload signal (`SIGUSR1`) once the app is attached, before that the signal would
kill `flutter run`, so dart-tools checks that the process handles it first.

## Goal
Run Flutter or Dart through terminal should be a good experience.

## What it won't be
A replacement for tools such as [flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim).

I just personally likes to use the terminal commands with Tmux

Currently includes
- [x] Hot reload when running through terminal
- [ ] ???
