---
layout: markdown_page
title: "Cheatsheet: Vim"
---

## Code formatting

- `:set list`, `\l` - show invisibles
- `:retab!` - auto converting between tabs and spaces 
  - `:set expandtab`, `retab!` - to spaces
  - `:set noexpandtab`, `retab!` - to tabs
- `.` - repeat

## Normal mode

- `h`, `j`, `k`, `l` - left, down, up, right
- `gj` - go down display line
- `gk` - go up display line
- `0` - to the first character of real line
- `g0` - to the first character of display line
- `^` - to the first nonblank character of line
- `g^` - to the first nonblank character of display line
- `$` - to the end of real line
- `g$` - to the end of display line
- `w` - forward to start of next word
- `W` - to the next WORD
- `b` - backward to start of current/previous word
- `B` - backward to start of current/previous WORD
- `e` - forward to end of current/next word
- `E` - forward to end of current/next WORD
- `ge` - backward to end of previous word
- `gE` - backward to end of previous WORD
- `<number>G` - to the line
- `gg` - beginning of the file
- `G` - end of the file
- `^G` - show current line
- `%` - move to matching brackets
- `f<char>` - find next
- `F<char>` - find backward
- `t<char>` - find next char and place cursor before
- `T<char>` - find next char and place cursor before backward
- `;` - go to the next of `f`/`t`
- `,` - go to previous of `f`/`t`
- `g;` - back to the last change
- `g,` - forward to the next change
- `:changes` - list changes
- `{number}+` - go to the `{number}` lines down
- `{number}-` - go to the `{number}` lines up

## Marks

- `m{a-zA-Z}` - set a mark
- `` `{mark}`` - go to the exact mark place
- `'{mark}` - go the first non-whitespace character on where mark was set

### Automatic marks
 
- `` ` `` - Position before the last jump within current file
- `.` - Location of last change
- `^` - Location of last insertion
- `[` - Start of last change or yank
- `]` - End of last change or yank
- `<` - Start of last visual selection
- `>` - End of last visual selection

## Search

- `/<text>` - forward search
  - `d/ge` - delete till you find `ge`
  - `v/ge` - select till `ge`
  - `/{text}\c` - case insensitive
  - `/{text}\C` - case sensitive
  - `/\v{regex}` - very magic search (more close to regex)
  - `/\V{text}` - very nomagic
  - `/\v<{word}>` - search for the word
  - `\zs`, `\ze` - helps to define boundaries of a match, for example `/Practical \szVim<CR>`
- `?<text>` - backward search
- `:hlsearch` - highlight search results
- `*` - find next current word
- `n` - next occurrence in same direction
- `N` - next occurrence in opposite direction

## Substitution

- `:[range]s/{pattern}/{string}/{flags} [count]` - replace

### Flags

- `g` - globally (within line)
- `c` - confirm changes
  - `y` to substitute this match
  - `n` to skip this match
  - `esc` to skip this match
  - `a` to substitute this and all remaining matches {not in Vi}
  - `q` to quit substituting {not in Vi}
  - `⌃E` to scroll the screen up {not in Vi}
  - `⌃Y` to scroll the screen down {not in Vi}
- `&` - same flags as previous invocation of substitute
- `e` - subpress errors
- `i` - ignore case for the pattern
- `I` - don't ignore case for the pattern
- `p` - print the line containing last substitute

### Range

- `%` - whole file
- `<n>,<m>` - between lines (including)

### Special characters for the replacement string

- `\r` - carriage return
- `\t` - tab
- `\\` - single backslash
- `\1` - first submatch
- `\0`, `&` - entire matches pattern
- `~` - use string from previous invocation of substitute
- `\={Vim script}` - evaluate script

## Edit

- `O` - insert line above the cursor
- `o` - insert line below the cursor
- `A` - start typing at the end of line
- `I` - start typing at the beginning of the line
- `a` - start typing after cursor
- `i` - start typing in place of cursor
- `C` - replace from cursor to the end of the line
- `S` - replace whole line
- `s` - replace current selection
- `x` - replace under cursor
- `r<char>` - replace char under cursor with
- `gr` - virtual replace, if tabs = spaces
- `R` - in place replacement (more than one letter)
- `gR` - virtual replace, if tabs = spaces
- `{register}d{motion}` - delete {motion}
- `"_d{motion}` - to delete in black hole (not a cut)
- `c<motion>` - change
- `{register}y<motion>` - yank
- `~<motion>` - swap case (when selected)
- `u<motion>` - lowercase (when selected)
- `U<motion>` - uppercase (when selected)
- `><motion>` - shift right (`>>` line)
- `<<motion>` - shift left (`<<` line)
- `=<motion>` - autoindent
- `u`, `:u[ndo]` - ungo changes
- `⌃R`, `:red[o]` - redo changes
- `U` - undo all latest changes on the line

## Insert mode

- `⌃w` - delete word
- `⌃u` - delete line
- `⌃b` - backspace
- `⌃[` - as escape
- `⌃o` - insert Normal Mode (just for one command)
- `⌃r{register}` - paste in insert mode
- `⌃r={expression}` - evaluate expression and paste
  - `:let i = 1`
  - `^r=i<CR>` - insert i from let
- `⌃v[u]{digit}` - insert letter by code
- `⌃k{char1}{char2}` - insert letter by :diagraphs (<< >> 12 14 34) see `:diagraph-table`

## Visual mode

- `v` - character-wise
- `V` - line-wise
- `⌃v` - block-wise
- `gv` - reselect
- `o` - go to the other end of the highlighted text

## Motions

- `a)`, `ab` - a pair of `(parentheses)`
- `i)`, `ib` - inside of `(parentheses)`
  -  `ci)` - replace everything inside `(...)`
- `a}`, `aB` - a pair of `{braces}`
- `i}`, `iB` - inside of `{braces}`
- `a]` - a pair of `[brackets]`
- `i]` - inside of `[brackets]`
- `a>` - a pair of `<angle brackets>`
- `i>` - inside of `<angle brackets>`
- `a'` - a pair of `'single quotes'`
- `i'` - inside of `'single quotes'`
- `a"` - a pair of `"double quotes"`
- `i"` - inside of `"double quotes"`
- `` a` `` - a pair of `backtricks`
- `` i` `` - inside of backtricks
- `at` - a pair of `<xml>tags</xml>`
- `it` - inside of `<xml>tags</xml>`
- `iw` - current word
  - `ciw` - replace current word.
- `aw` - current word plus one space
  - `daw` - delete word and one space after it.
- `iW` - current WORD
- `aW` - current WORD plus one space
- `is` - current sentence
- `as` - current sentence plus one space
- `ip` - current paragraph
- `ap` - current paragprah plus one blank line

## Yanking

- `{register}p` - paste text
  - `:put {register}` - paste from register below current line
  - `⌃r{register}` - paste in insert mode, where register can be `"`, `0` , `+`
  - `gp` - paste and place cursor at the end of pasted text
- `{register}P` - paste previous
- `{register}y{motion}` - yank
  - `yy` - yank the line
  - by default yank always puts everything into unnamed and 0 registers
  - uppercase registes are used for append
  - `"+`, `"*` - system clipboard
- `:reg` - see content of all registers
  - `"%` - name of current file
  - `"#` - name of the alternate file
  - `".` - last inserted text
  - `":` - last Ex command
  - `"/` - last search pattern

## Windows

- `⌃w w` - next window
- `⌃w h` - next window on left
- `⌃w j` - next window below
- `⌃w k` - next window above
- `⌃w l` - next window rigth
- `⌃w c`, `:close`, `:cl` - close current window
- `⌃w o`, `:only`, `:on` - keep only current window open
- `⌃w =` - equalize width and height of all windows
- `⌃w _` - maximize height of active window
- `⌃w |` - maximize width of active window
- `{n} ⌃w _` - set active window height to `{n}` rows
- `{n} ⌃w |` - set active window width to {n} rows
- `⌃w s`, `:split {filename}` - split by horizontally
- `⌃w v`, `:vsplit {filename}` - split by vertically
- `⌃w H`, `⌃w J`, `⌃w K`, `⌃w L` - swap windows (`:help window-moving`)
- `⌃w x` - rotate current window (`:help window-moving`)
- `⌃w r` - rotate all windows (`:help window-moving`)
- `^w z` - close preview window

## Tabs

- `:tabedit {filename}`, `:tabe {filename}` - open filename in new tab
- `^w T` - move current window into its own tab
- `:tabc[lose]` - close current tab
- `:tabo[nly]` - keep the active tab page
- `{N}gt`, `:tabn[ext] {N}`  - switch to tab page number `{N}`
- `gt`, `:tabn[ext]` - switch to next tab
- `gT`, `:tabp[revious]` - switch to the previous tab
- `:tabmove [N]` - rearrange the tab

## Buffers

- `:ls` - list of buffers
- `[b`, `:bn[ext]` - next buffer
- `]b`, `:bp[revious]` - previous buffer
- `[B`, `:bfirst` - go to the first in the buffer
- `]B`, `:blast` - go to the last in the buffer
- `:buffer N` - go to the buffer N
- `⌃-^` - alternate file
- `:bd[elete]` - delete current buffer
- `:bufdo {command}` - execute command for each buffer

## Args

- `:args` - see args passed to the vim
- `:args {list}` - build arguments list
  - `:args **/*.js **/*.css` - load all js and css files in args
- `:argdo command` - execute command on each argument
  - `:argdo normal @a` - execute macro a for each file in args
  - `:argdo write` - write all files
- `]a`, `:next` - go to the next in args
- `[a`, `:prev` - go to the prev in args
- `]A`, `:first` - go to the first in args
- `[A`, `:last` - go to the last in args

## Jumps

- `⌃o` - jump to previous location
- `⌃i` - jump to forward location
- `:jumps` - show all jumps
- `^]` - jump to definition of keyword under the cursor
  - Use ctags to generate ctags file
  - `⌃t`, `:pop` - to navigate back for our tag history
  - `g ⌃]>` - if multiple matches - show choices
  - `:tselect`, `:tnext`, `:tprev`, `:tfirst`, `:tlast` - navigate between multiple choices
  - `:tag {keyword}` - jump to definition
  - `:tjump {keyword}` - jump and ask for multiple
  - `:tjump /{regex}` - try to find
- `gf` - jump to file name under the cursor
  - `:set suffixesadd+=.rb` to add specific suffix `:set path+=,%:h` to add current directory
- `(`, `)` - jump to start of previous/next sentence
- `{`, `}` - jump to start of previous/next paragraph

## Command line mode

- `ga` - find code of selected character
- `:set nowrap` - unwrap lines
- `:setlocal spell` - turn on spell check
- `@:` - repeat the last ex command
- `⌃r`, `⌃w` - copy and paste current word to the command line
- `⌃p`, `Up` - previous item from history
- `⌃n`, `Down` - next item from history
- `q:` - see history of command line
- `q/` - see history of searches
- `:sh` - go to shell
- `:e <filename>` - open file name for edit
  - `:e!` - re-read file from the disk (discard all changes)
  - `:e %<Tab>` - to get edit current opened file
  - `:e %:h<Tab>` - to get edit directory of current opened file
- `:w <filename>` - write current to file (whole file or selection)
- `:wall` - write all buffers
- `:update <filename>` - same as write, but only if modified
- `:r <command|filename>` - read from external file or command and paste
- `:!{command}` - execute command with shell
  - `:2,$!sort -t',' -k2` - sort all lines except header by second column
  - `read !{cmd}` - execute `cmd` in shell and insert its stdout below cursor
  - `:[range]write !{cmd}` - execute `cmd` in the shell with `[range]` lines as stdin
- `:[range]t {address}`, `:[range]co[py] {address}` - copy line(s) from [range] and paste to {address}
  - `.` - instead of address means current line
  - `:6copy.` - copy from line 6 and insert on current line
  - `:t6` - copy current line to below line 6
  - `:t.` - duplicate the current line
  - `:t$` - copy the current line to the end of the file
  - `'<,'>t0` - copy the visually selected lines to the start of the file
- `:[range]m[ove] {address}` - move line(s) from [range] and paste to {address}
- `:[range]normal {command}` - execute command on selected range
  - `:%normal i//` - instead `//` for whole file (command all lines)
  - `'<,'>normal .` - repeat last command for selected lines
- `:[range] gloabl[!] /{pattern}/ [cmd]` - execute command on range with matched pattern
  - `:v`, `:vglobal` - execute cmd on each line which does not match pattern
- `:sort` - sort selected lines
- `:grep` - grep in files
  - `:grep -R Quickfix *` - search in all directories
- `:vim[grep][!] /{pattern}/[g][j] {file} ...` - search with internal vim grep
  - `g` - multiple matches on the same line
  - `j` - don't jump to first match
- `:make` - execute make command
  - `:setlocal makepkg=NODE_DISABLE_COLORS=1\ nodelint\ %` - change make program
  - `:setglobal errorformat?` - see how errors are getting formatted
  - `:compiler` - to set compiler

## Macros

- `q{register}{macro}q` - start recording macros
  - Uppercase register appends to the macro
- `@{register}` - replay macro
  - `10@a` - execute 10 times macro from register `a`

## Quickfix

- `:cnext` - jump to next item
- `:cprev` - jump to previous item
- `:cfirst` - jump to first item
- `:clast` - jump to last item
- `:cnfile` - jump to first item in next file
- `:cpfile` - jump to last item in previous file
- `:cc N` - jump to Nth item
- `:copen` - open the quickfix window
- `:cclose` - close the quickfix window
- `:colder` - older version of the quickfix list
- `:cnewer` - newer version of the quickfix list

## Autocompletition

- `⌃n` - generic keywords
- `⌃p` - generic keywords (previous)
- `⌃y` - accept the currently selected match (yes)
- `⌃e` - revert to the originally typed text
- `⌃h` - delete one character from current match
- `⌃l` - add one character from current match
- `⌃x ⌃n` - current buffer keywords
- `⌃x ⌃i` - included file keywords
- `⌃x ⌃]` - tags file keywords
- `⌃x ⌃k` - dictionary lookup
  - `:set spell` should be enabled
- `⌃x ⌃l` - whole line completion
- `⌃x ⌃f` -filename completion
  - `:pwd` - to from where autocompletion will work
  - `:cd public` - to change to folder
  - `:cd -` - to previous working directory
- `⌃x ⌃o` - omni-completion

## Vim spell checker

- `:set spell` - enable spell checking
  - `spellfile` to share file with custom words
- `:set spelllang=en_us` - change speaking region
- `[s` - previous error
- `]s` - next error
- `z=` - fix error
- `zg` - add current word to spell file
- `zw` - remove current word from the spell file
- `zug` - revert `zg` or `zw` command for current word
- `⌃x s` - fix misspelled word in insert mode

## Foldings

- `zi` - switch folding on or off
- `za` - toggle current fold open/closed
- `zc` - close current fold
- `zR` - open all folds
- `zM` - close all folds
- `zv` - expand folds to reveal cursor
- `zj` - move down to top of next fold
- `zk` - move up to bottom of previous fold
- `zo` - open current fold
- `zO` - recursively open current fold
- `zc` - close current fold
- `zC` - recursively close current fold
- `za` - toggle current fold
- `zA` - recursively open/close current fold
- `zm` - reduce foldlevel by one
- `zM` - close all folds
- `zr` - increase foldlevel by one
- `zR` - open all folds

## Exit/Save

- `:q[uit]` - quit vim
- `:q[uit]!` - quit without saving
- `:cq[uit]` - quit always, without writing
- `ZZ`, `:wq` - write and quit
- `ZQ`, `:wq!` - write current file and exit always
- `:wq {file}` - write to `{file}` and exit after

## Vim from command line

- `vim -u NONE -N` - launch vim without settings

## Plugins

### surround.vim

- `S"` - surround selection with `"`
- `cs}]` - change surrounding from `}` to `]`

### pymode

> [https://github.com/klen/python-mode](https://github.com/klen/python-mode)

- `K` - show help for current symbol
- ` [ [ ` - Jump to previous class or function (normal, visual, operator modes)
- ` ] ] ` - Jump to next class or function  (normal, visual, operator modes)
- `[M` - Jump to previous class or method (normal, visual, operator modes)
- `]M` - Jump to next class or method (normal, visual, operator modes)
- `aC` - Select a class. Ex: vaC, daC, yaC, caC (normal, operator modes)
- `iC` - Select inner class. Ex: viC, diC, yiC, ciC (normal, operator modes)
- `aM` - Select a function or method. Ex: vaM, daM, yaM, caM (normal, operator modes)
- `iM` - Select inner function or method. Ex: viM, diM, yiM, ciM (normal, operator modes)
- `^r` - Run script
- `^b` - Set breakpoint

#### Rope

- `^c-d` - Show doc
- `^c-rr` - Rename
- `^c-r1r` - Rename module
- `^c-ro` - Organize imports
- `^c-r1p` - Convert module to package
- `^c-rm` - Extract method
- `^c-rl` - Extract variable
- `^Space` - Rope completion
