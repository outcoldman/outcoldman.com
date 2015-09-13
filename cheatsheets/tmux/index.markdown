---
layout: post
title: "Cheatsheet: tmux"
tags: [tmux,cheatsheet]
date: 2015/09/13
---

## Command line

* `tmux new -s {session_name} -n {name}` - create new session and specify window name
* `tmux {attach|a|at} -t {session_name}` - attach to session
* `tmux ls` - list sessions
* `tmux kill-session -t {session_name}` - kill session

## Misc

* `Prefix ?` - help
* `Prefix d` - detach
* `Prefix t` - big clock

## Command mode

* `Prefix :` - command mode
* `new-window -n {name} {command}` - create new window and execute command

## Sessions

* `:new` - new session
* `Prefix s` - list sessions
* `Prefix $` - name session
* `Prefix (` - previous session
* `Prefix )` - next session
* `Prefix L` - last session

## Windows

* `Prefix c` - create new window
* `Prefix ,` - rename window
* `Prefix n` - next window
* `Prefix p` - previous window
* `Prefix {n}` - go to window n
* `Prefix f` - find window by name
* `Prefix w` - list windows
* `Prefix &` - kill window

## Panes

* `Prefix %` split panes by vertical (see [tmux-pain-control](#tmux_plugins_tmux-pain-control_splitting))
* `Prefix "` split panes by horizontal (see [tmux-pain-control](#tmux_plugins_tmux-pain-control_splitting))
* `Prefix o` - cycle through the panes
* `Prefix {arrow key}` - navigate to specific pane (see [tmux-pain-control](#tmux_plugins_tmux-pain-control_splitting))
* `Prefix space` - cycle thought layouts
* `Prefix x` - close pane
* `Prefix q` - show panes numbers
* `Prefix z` - switch to whole window mode and back
* `Prefix {` - move the current pane left (see [tmux-pain-control](#tmux_plugins_tmux-pain-control_swapping-panes))
* `Prefix }` - move the current pane right (see [tmux-pain-control](#tmux_plugins_tmux-pain-control_swapping-panes))
* `:setw synchronize-panes` - toggle panes synchronization

## Copy mode (vi mode)

* `Prefix [` - start copy mode
* `Prefix ]` - past from copy mode
* `^` - back to indentation
* `esc` - clear selection
* `enter` - copy selection
* `j` - cursor down
* `h` - cursor left
* `l` - cursor right
* `k` - cursor down
* `L` - cursor to bottom line
* `M` - cursor to middle line
* `H` - cursor to top line
* `d` - delete entire line
* `D` - delete to end of line
* `$` - end of line
* `:` - goto line
* `⌃-d` - half page down
* `⌃-u` - half page up
* `⌃-f` - next page
* `w` - next word
* `p` - paste buffer
* `⌃-b` - previous page
* `b` - previous word
* `q` - quit mode
* `⌃-down`, `⌃-j` - scroll down
* `⌃-up`, `⌃-k` - scroll up
* `n` - next search match
* `?` - search backward
* `/` - search forward
* `0` - start of line
* `space` - start selection

## Settings

* `set -g mode-mouse on` - enable mouse support

## Plugins

### tmux-copycat

> [https://github.com/tmux-plugins/tmux-copycat](https://github.com/tmux-plugins/tmux-copycat)

- `prefix + /` - regex search (strings work too)

#### Predefined searches

- `prefix + ctrl-f` - simple *f*ile search
- `prefix + ctrl-g` - jumping over *g*it status files (best used after `git status` command)
- `prefix + alt-h` - jumping over SHA-1 hashes (best used after `git log` command)
- `prefix + ctrl-u` - *u*rl search (http, ftp and git urls)
- `prefix + ctrl-d` - number search (mnemonic d, as digit)
- `prefix + alt-i` - *i*p address search

### tmux-open

> [https://github.com/tmux-plugins/tmux-open](https://github.com/tmux-plugins/tmux-open)

- `o` - "open" a highlighted selection with the system default program. `open`
    for OS X or `xdg-open` for Linux.
- `⌃-o` - open a highlighted selection with the `$EDITOR`

### tmux-pain-control

> [https://github.com/tmux-plugins/tmux-pain-control](https://github.com/tmux-plugins/tmux-pain-control)

#### Navigation

- `Prefix + h`, `Prefix + C-h` - select pane on the left
- `Prefix + j`, `Prefix + C-j` - select pane below the current one
- `Prefix + k`, `Prefix + C-k` - select pane above
- `Prefix + l`, `Prefix + C-l` - select pane on the right

#### Resizing

- `Prefix + shift + h` - resize current pane 5 cells to the left
- `Prefix + shift + j` - resize 5 cells in the up direction
- `Prefix + shift + k` - resize 5 cells in the down direction
- `Prefix + shift + l` - resize 5 cells to the right

#### Splitting

- `Prefix |` split panes by vertical
- `Prefix -` split panes by horizontal

#### Swapping panes

- `Prefix <` moves current pane one position to the left
- `Prefix >` moves current pane one position to the right

### tmux-resurrect

> [https://github.com/tmux-plugins/tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)

- `Prefix ⌃-s` - save
- `Prefix ⌃-r` - restore

### tmux-yank

> [https://github.com/tmux-plugins/tmux-yank](https://github.com/tmux-plugins/tmux-yank)

- `Prefix - y` -  copies text from the command line to clipboard

#### copy mode

- `y` - copy selection to system clipboard
- `Y` - copy selection and paste it to the command line

### vim-tmux-navigator

> [https://github.com/christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)

- `⌃-h` - Left
- `⌃-j` - Down
- `⌃-k` - Up
- `⌃-l` - Right
- `⌃-\ ` - Previous split

### tmuxinator

> [https://github.com/tmuxinator/tmuxinator](https://github.com/tmuxinator/tmuxinator)

### tmux-sensible

> [https://github.com/tmux-plugins/tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)

### tpm

> [https://github.com/tmux-plugins/tpm](https://github.com/tmux-plugins/tpm)
