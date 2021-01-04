---
categories: en
date: "2015-09-13T00:00:00Z"
tags:
- tmux
- vim
- iterm
- bash
- zsh
- terminal
- vundle
- antigen
- zgenjj
title: Keep your sh together
slug: "keep-your-sh-together"
---

If you are working in terminal - one of the important things is to keep
your scripts and dotfiles in the order. Basically, you should consider
them as one of your regular pet/side projects,
and as any other of your pet projects:

- *you should* be able to easily contribute to it;
- *you should* have a good way to maintain dependencies;
- *you should* make it reusable;

I am a Terminal user, I use combination of *tmux*, *zsh* and *vim* for everyday
development. In this post I just want to share with you my dotfiles and
few ideas/plugins I use to maintain my scripts and configuration. Hope that it
may be useful for you as a reference.

Also I published two of my cheatsheets:
[vim]({{site.url}}/cheatsheets/vim/) and [tmux]({{site.url}}/cheatsheets/tmux/)

[![iTerm2](/library/2015/09/my-iterm2.png)](/library/2015/09/my-iterm2.png)

## What to use?

If you were Windows user as me you probably have heard a lot of "Linux is great
because it has bash". And that is true, `bash` is great, but it is not only one
shell is installed on your system (I'm on *OS X 10.11*)

```bash
# ls /bin/*sh
/bin/bash /bin/csh  /bin/ksh  /bin/sh   /bin/tcsh /bin/zsh
```

It is one of the popular, but there are
alternatives. One of the alternatives is [zsh](http://zsh.org). You probably
have heard about [oh-my-zsh](http://ohmyz.sh) which
people blindly install because of nice prompts you can get with it. But it is
much more than just a theme for your prompt. It is a good tool to manage your
dotfiles, scripts and configurations, but it works better if you understand
why you install it and which tools works great with it.

### zsh

> Zsh is a shell designed for interactive use, although it is also a powerful scripting language. 

Why people choose zsh over bash?

Short answer: if we will compare it to `bash` it has much better competition and
expansion. For some reason *OS X* also has very outdated version of `bash`.

Long answer: to see all benefits of `zsh` read [From Bash to Z Shell](http://www.bash2zsh.com)
or at least start with [Master Your Z Shell with These Outrageously Useful Tips](http://reasoniamhere.com/2014/01/11/outrageously-useful-tips-to-master-your-z-shell/).

`bash` and `zsh` are very similar in syntax and most of builtin commands are
the same, but you need to know that not everywhere you will be able to get
`zsh`, somewhere you maybe will not have access to `bash` only `sh`.

### oh-my-zsh

> A delightful community-driven framework for managing your zsh configuration.
> Includes 200+ optional plugins (rails, git, OSX, hub, capistrano, brew, ant, php, python, etc),
> over 140 themes to spice up your morning, and an auto-update tool so that makes it easy
> to keep up with the latest updates from the community.

One of the reasons why I use [oh-my-zsh](http://ohmyz.sh) because of great set of
[plugins](https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins). Also as
we already discussed it has nice [themes](https://github.com/robbyrussell/oh-my-zsh/wiki/Themes).
Also I highly recommend to take a look on [cheatsheet](https://github.com/robbyrussell/oh-my-zsh/wiki/Cheatsheet).

### tmux

> [tmux](http://tmux.github.io) is a terminal multiplexer
>
> What is a terminal multiplexer? It lets you switch easily between several
> programs in one terminal, detach them (they keep running in the background)
> and reattach them to a different terminal. And do a lot more. See the manual.

If you are Mac user you probably know about [iTerm2](https://iterm2.com). It has
[integration with tmux](https://gitlab.com/gnachman/iterm2/wikis/TmuxIntegration).
If you really want to feel benefit of tmux and make your life easier don't use
integration. You will not get benefit of tmux if you will cheat with iTerm2 and
still use mouse for few things. And don't just try tmux, if you really want to
get benefit from tmux - you should read some docs, maybe this book
[tmux. Productive Mouse-Free Development](https://pragprog.com/book/bhtmux/tmux).

### Vim

> Vim - the editor

[Vim](http://www.vim.org) is great. Will you believe me that I was a heavy
Visual Studio / ReSharper user, command line any non IDE editor hater and
now I am happy vim user?

Vim itself is great editor (especially considering how many plugins it has).
But it requires a lot of time to learn it. My timeline of learning vim was:

1. What is that, how do I exit it? When I started to learn git I just had a rule
to never commit without `-m`, because I could not understand how to exit this
*git editor*. Yes exactly, *the git editor*, this is what I used in my Google
searches to find how to exit it. I had no idea that it was Vim.
2. I installed, learned how to exit it, learned about two modes and started to
tell people that I know Vim. I was able to write a git commit message and even
edit few configuration files.
3. I read few articles and installed a lot of plugins. I was a little bit more
advanced Vim lammer. Plugins made Vim look cool and I started to enjoy it more.
I making Vim to look more like any non-Vim editor.
4. I read few vimrc files, read more articles about Vim, and more important I
have read [Practical Vim](https://pragprog.com/book/dnvim/practical-vim).
I wrote my own vimrc file and started to use Vim for small things like: small
updates in source code, conf files, writing markdown text.
5. My current stage. I'm very careful about plugins, before installing them
at first I read docs and configure them in the way I think it should work.
I feel more comfortable with Vim and Pythong-mode than with PyCharm, or Vim and
Vim-go than with Sublime Text, or using Vim for C++ development than Xcode.

One more important thing, use Vim in terminal, don't use MacVim. MacVim is great
but if you want to be really productive you should learn Vim in terminal, using
it with tmux is really great combination.

To manage plugins for Vim I use [vundle](https://github.com/VundleVim/Vundle.vim).

### git

Git is great for managing your own scripts and dotfiles. You want to have a
history and you want to have a very simple way to sync changes between multiple
work environments. Using public git repositories is hard for dotfiles, I prefer to keep
my dotfiles private, because it is easy to keep private things in private repository,
like some functions/scripts for new feature I'm working on right now. Or maybe
links to private company websites and repositories.
I tried at first to write some kind of *dotfiles framework* which can be reusable
and easy to maintain, but considering how often you change things - it is really
hard to do.

### zgen

Most of the peoples use [antigen](http://antigen.sharats.me), which looks more
like dead than alive. It has huge issue with performance, depending on how many
plugins you defined in your `zshrc` file - antigen can spend more than few
seconds in [parsing its sugar syntax](https://github.com/zsh-users/antigen/pull/141).
But at the end I just switched to [zgen](https://github.com/tarjoilija/zgen),
which is much faster. The only one problem with `zgen` if you update your
`zshrc` file you need to reset the cache with `zgen reset`. I had only
one issue with it, when you are switching to *root*, but author took my
[pull request](https://github.com/tarjoilija/zgen/pull/41) so no more issues.

## My setup

### Installation

I store my *dotfiles* in Git on my own GitLab server at home. On any computer
with zsh I clone my repository in `~/.dotfiles`

```bash
git clone \
    ssh://git@gitlab.example.com/outcoldman/dotfiles.git \
    ~/.dotfiles \
    --recursive
```

Content of cloned folder is

```
.git/
.gitignore
.gitmodules
dots/
install.zsh*
plugins/
powerline-fonts/
scripts/
settings/
vim/
zgen/
```

I have two submodules `zgen` and `powerline-fonts`. I may consider to actually
move them to `install.zsh` script, so it will be easier to work with them. But
for now they are submodules.

Also in the root folder I have

- `dots` - my dotfiles
- `plugins` - my `zsh` plugins
- `scripts` - few python / shell / some other scripts I downloaded / wrote.
- `settings` - folder to sync [Alfred](https://www.alfredapp.com), [iTerm](https://iterm2.com) and
    [Sublime Text](http://sublimetext.com) (I keep Sublime just in case if somebody else
    will need to use my computer).


My `install.zsh` looks like

```
#!/bin/zsh

# Change shell for current user to zsh
if [ ! "$SHELL" = "/bin/zsh" ]; then
  chsh -s /bin/zsh
fi

# remove old dot files
rm ~/.gitconfig
rm ~/.gitignore_global
rm ~/.tmux.conf
rm ~/.vimrc
rm ~/.zshrc

# link new dot files
ln ~/.dotfiles/dots/home/gitconfig               ~/.gitconfig
ln ~/.dotfiles/dots/home/gitignore_global        ~/.gitignore_global
ln ~/.dotfiles/dots/home/tmux.conf               ~/.tmux.conf
ln ~/.dotfiles/dots/home/vimrc                   ~/.vimrc
ln ~/.dotfiles/dots/home/zshrc                   ~/.zshrc

# Do special to sync sublime settings on OS X
if [[ "$OSTYPE" =~ "darwin" ]]; then
  rm ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

  ln -s ~/.dotfiles/settings/SublimeText/User      ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
fi


# install powerline fonts
~/.dotfiles/powerline-fonts/install.sh
```

> Just to be clear here and later I clear listing of all files from information
> which I consider unnecessary, like work specific.

### zshrc

Let's take a look on the content of `zshrc`

```
#!/bin/zsh

# If I see that zsh takes to much time to load I profile what has been changed,
# I want to see my shell ready in not more than 1 second
PROFILING=${PROFILING:-false}
if $PROFILING; then
    zmodload zsh/zprof
fi

# Location of my dotfiles
DOTFILES=$HOME/.dotfiles

# Update PATH
path=(
    /usr/local/{bin,sbin}
    $DOTFILES/scripts
    $path
)
typeset -U path

# if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# change the size of history files
export HISTSIZE=32768;
export HISTFILESIZE=$HISTSIZE;

# Shell
export CLICOLOR=1
export EDITOR='vim'
export PAGER='less'

# Homebrew
# This is one of examples why I want to keep my dotfiles private
export HOMEBREW_GITHUB_API_TOKEN=MY_GITHUB_TOKEN
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Autoenv https://github.com/Tarrasch/zsh-autoenv
# Great plugin to automatically modify path when it sees .env file
# I use it for example to automatically setup docker/rbenv/pyenv environments
AUTOENV_FILE_ENTER=.env
AUTOENV_FILE_LEAVE=.envl

# tmux plugin settings
# this always starts tmux
ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOSTART_ONCE=true
ZSH_TMUX_FIXTERM=true
ZSH_TMUX_AUTOQUIT=false

# Powerlevel9k is the best theme for prompt, I like to keep it in dark gray colors
DEFAULT_USER=outcoldman
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
POWERLEVEL9K_DIR_BACKGROUND='238'
POWERLEVEL9K_DIR_FOREGROUND='252'
POWERLEVEL9K_STATUS_BACKGROUND='238'
POWERLEVEL9K_STATUS_FOREGROUND='252'
POWERLEVEL9K_CONTEXT_BACKGROUND='240'
POWERLEVEL9K_CONTEXT_FOREGROUND='252'
POWERLEVEL9K_TIME_BACKGROUND='238'
POWERLEVEL9K_TIME_FOREGROUND='252'
POWERLEVEL9K_HISTORY_BACKGROUND='240'
POWERLEVEL9K_HISTORY_FOREGROUND='252'

# dumb terminal can be a vim dump terminal in that case don't try to load plugins
if [ ! $TERM = dumb ]; then
    ZGEN_AUTOLOAD_COMPINIT=true

    # If user is root it can have some issues with access to competition files
    if [[ "${USER}" == "root" ]]; then
        ZGEN_AUTOLOAD_COMPINIT=false
    fi

    # load zgen
    source $DOTFILES/zgen/zgen.zsh

    # configure zgen
    if ! zgen saved; then

        # zgen will load oh-my-zsh and download it if required
        zgen oh-my-zsh

        # list of plugins from zsh I use
        # see https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
        zgen oh-my-zsh plugins/bower
        zgen oh-my-zsh plugins/brew
        zgen oh-my-zsh plugins/colored-man
        zgen oh-my-zsh plugins/docker
        zgen oh-my-zsh plugins/git
        zgen oh-my-zsh plugins/git-extras
        zgen oh-my-zsh plugins/gitignore
        zgen oh-my-zsh plugins/go
        zgen oh-my-zsh plugins/node
        zgen oh-my-zsh plugins/npm
        zgen oh-my-zsh plugins/osx
        zgen oh-my-zsh plugins/pip
        zgen oh-my-zsh plugins/python
        zgen oh-my-zsh plugins/sudo
        zgen oh-my-zsh plugins/tmuxinator
        zgen oh-my-zsh plugins/urltools
        zgen oh-my-zsh plugins/vundle
        zgen oh-my-zsh plugins/web-search
        zgen oh-my-zsh plugins/z

        # https://github.com/Tarrasch/zsh-autoenv
        zgen load Tarrasch/zsh-autoenv
        # https://github.com/zsh-users/zsh-completions
        zgen load zsh-users/zsh-completions src

        # my own plugins
        zgen load $DOTFILES/plugins/aliases
        zgen load $DOTFILES/plugins/dotfiles
        zgen load $DOTFILES/plugins/my-aws
        zgen load $DOTFILES/plugins/my-azure
        zgen load $DOTFILES/plugins/my-brew
        zgen load $DOTFILES/plugins/my-digitalocean
        zgen load $DOTFILES/plugins/rbenv
        zgen load $DOTFILES/plugins/pyenv
        zgen load $DOTFILES/plugins/tpm

        # load https://github.com/bhilburn/powerlevel9k theme for zsh
        zgen load bhilburn/powerlevel9k powerlevel9k.zsh-theme

        # It takes control, so load last
        zgen load $DOTFILES/plugins/my-tmux

        zgen save
    fi

    # Configure vundle
    vundle-init
fi

# specific for machine configuration, which I don't sync
if [ -f ~/.machinerc ]; then
    source ~/.machinerc
fi


# additional configuration for zsh
# Remove the history (fc -l) command from the history list when invoked.
setopt histnostore
# Remove superfluous blanks from each command line being added to the history list.
setopt histreduceblanks
# Do not exit on end-of-file. Require the use of exit or logout instead.
setopt ignoreeof
# Print the exit value of programs with non-zero exit status.
setopt printexitvalue
# Do not share history
setopt no_share_history

# if profiling was on
if $PROFILING; then
    zprof
fi
```

As you can see I keep all my custom plugins under plugins folder, all of my
plugins just some set of functions like `my-brew/my-brew.plugin.zsh`

```bash
#!/bin/zsh

brew-essentials() {
  brew install cloc
  brew install cmake
  brew install coreutils
  brew install ctags
  brew install cv
  brew install docker
  brew install docker-compose
  brew install docker-machine
  brew install git
  brew install gotags
  brew install hr
  brew install httpie
  brew install icdiff
  brew install jq
  brew install lnav
  brew install mercurial
  brew install ncdu
  brew install node
  brew install p7zip
  brew install pstree
  brew install pyenv
  brew install ranger
  brew install rbenv
  brew install ruby-build
  brew install sqlite
  brew install ssh-copy-id
  brew install the_silver_searcher
  brew install tmux
  brew install vim
  brew install watch
  brew install zsh
}
```

Or for example some of them to work in special configurations like
`my-aws/my-aws.plugin.zsh` (another reason to keep my dotfiles private)

```bash
#!/bin/zsh

# Docker
docker-machine-aws() {
    export AWS_ACCESS_KEY_ID=MY_AWS_KEY
    export AWS_SECRET_ACCESS_KEY=MY_AWS_SECRET
    export AWS_VPC_ID=MY_VPC_ID
    export AWS_DEFAULT_REGION=us-west-2
}
```

> For securtiy reasons I do not recommend to export these variables every time
> your zsh profile is loading. Only load it in sessions where you really need it.

Some plugins automatically load special things, like `tpm/tpm.plugin.zsh`

```bash
#!/bin/zsh

# If Tmux Plugin Manager is not installed - clone it
if [[ ! -d ~/.tmux/plugins/tpm/.git ]]; then
    git clone git@github.com:tmux-plugins/tpm.git ~/.tmux/plugins/tpm
fi
```

Also I have my special plugin which load oh-my-zsh tmux plugin only when I'm
not in SSH and not root

```
#!/bin/zsh

# It takes control, so load last
# Load only when we are default user (not root) and not in ssh
if [[ ${DEFAULT_USER} == ${USER} ]] && [[ -z ${SSH_CLIENT} ]]; then
    source $ZSH/plugins/tmux/tmux.plugin.zsh
fi
```

### tmux.conf

As you have seen I use [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
for tmux, which allows me to load few things from Tmux.

```bash
# List of plugins

# These are all plugins I load from GitHub, first is Tmux Plugin Manager
set -g @plugin 'tmux-plugins/tpm'
# Easy to search file/sha/url above
set -g @plugin 'tmux-plugins/tmux-copycat'
# Easy to open link / files from tmux
set -g @plugin 'tmux-plugins/tmux-open'
# Nice shortcuts for panes/windows
set -g @plugin 'tmux-plugins/tmux-pain-control'
# Basic tmux settings everyone can agree on
set -g @plugin 'tmux-plugins/tmux-sensible'
# Easy to paste selected text
set -g @plugin 'tmux-plugins/tmux-yank'
# Easy to switch between Vim and Tmux panes
set -g @plugin 'christoomey/vim-tmux-navigator'

# Smart pane switching with awareness of vim splits
is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?)(diff)?$"'
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
bind -n C-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"

# Few of my specific settings for tmux
set-option -g bell-action any
set-option -g prefix2 ^A
set-option -g base-index 1
set-option -g pane-base-index 1
set-option -g renumber-windows on

# Modify status bar, my theme
set-option -g status-interval 2
set-option -g status on
set-option -g status-utf8 on
set-option -g status-justify "centre"
set-option -g status-left-length 90
set-option -g status-right-length 90
set-option -g status-bg colour240
set-option -g status-fg white
set-option -g status-left '#[fg=colour244,bg=colour238] #S #[fg=colour238,bg=colour240]'
set-option -g status-right '#[fg=colour238]#[fg=colour244,bg=colour238] #H '
set-option -g window-status-format '#[fg=colour246]#I:#W#F'
set-option -g window-status-current-format '#[fg=colour252]#I:#W#F'

# Options available only after tmux 2.0
run-shell '[[ "$(tmux -V)" == tmux\ 1* ]] || tmux set-option -g message-command-style bg=colour241,fg=white'
run-shell '[[ "$(tmux -V)" == tmux\ 1* ]] || tmux set-option -g message-style bg=colour241,fg=white'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

I also use [tmuxinator](https://github.com/tmuxinator/tmuxinator) to predefine
some common used session.

Here also my [tmux cheatsheet]({{site.url}}/cheatsheets/tmux/).


### vimrc

My `vimrc` file, just use it for reference, don't try to really use it, I modify
it once in a week, update something, change something, it is maybe even broken
right now

```
" be iMproved
set nocompatible

" Load plugins (with vim-bundle)
filetype off
set runtimepath^=~/.vim/bundle/vundle
call vundle#begin()
    " See information abotu CtrlP below, this is faster search for it
    Plugin 'FelikZ/ctrlp-py-matcher'
    " Show icons for modified lines
    " https://github.com/airblade/vim-gitgutter
    Plugin 'airblade/vim-gitgutter'
    " vim syntax file for plantuml
    " https://github.com/aklt/plantuml-syntax
    Plugin 'aklt/plantuml-syntax'
    " vim syntax for yaml files
    " https://github.com/avakhov/vim-yaml
    Plugin 'avakhov/vim-yaml'
    " Nice status bar for Vim
    " https://github.com/bling/vim-airline
    Plugin 'bling/vim-airline'
    " Highlights trailing whitespace in red and provides :FixWhitespace to fix it.
    " https://github.com/bronson/vim-trailing-whitespace
    Plugin 'bronson/vim-trailing-whitespace'
    " Seamless navigation between tmux panes and vim splits
    Plugin 'christoomey/vim-tmux-navigator'
    " Syntax for dockerfile
    Plugin 'ekalinin/Dockerfile.vim'
    " Syntax for json files
    Plugin 'elzr/vim-json'
    " Support for golang
    Plugin 'fatih/vim-go'
    " Plugin manager
    Plugin 'gmarik/Vundle.vim'
    " Match tag for html tags
    Plugin 'gregsexton/MatchTag'
    " css3 syntax
    Plugin 'hail2u/vim-css3-syntax'
    " javascript additional syntax
    Plugin 'jelera/vim-javascript-syntax'
    " toggle cursor for vim
    Plugin 'jszakmeister/vim-togglecursor'
    " Full path fuzzy file, buffer, mru, tag, ... finder for Vim.
    " http://kien.github.io/ctrlp.vim/
    Plugin 'kien/ctrlp.vim'
    " Support for python
    Plugin 'klen/python-mode'
    " Support for typescript
    Plugin 'leafgarland/typescript-vim'
    " JavaScript indent plugin
    Plugin 'lukaszb/vim-web-indent'
    " Browser for tags
    Plugin 'majutsushi/tagbar'
    " Syntax for some javascript libraries
    Plugin 'othree/javascript-libraries-syntax.vim'
    " Support for markdown
    Plugin 'plasticboy/vim-markdown'
    " Ag search, use it instead of grep
    Plugin 'rking/ag.vim'
    " File browser
    Plugin 'scrooloose/nerdtree'
    " Syntax linters
    Plugin 'scrooloose/syntastic'
    " Monokai theme for vim
    Plugin 'sickill/vim-monokai'
    " Syntax for tmux files
    Plugin 'tmux-plugins/vim-tmux'
    " Make vim to work better in tmux
    Plugin 'tmux-plugins/vim-tmux-focus-events'
    " Git wrapper
    Plugin 'tpope/vim-fugitive'
    " Additional surround snippets
    Plugin 'tpope/vim-surround'
    " Good shortcuts for switching between different lists
    Plugin 'tpope/vim-unimpaired'
call vundle#end()

syntax enable
filetype plugin indent on

runtime macros/matchit.vim

" Colorsheme
set background=dark
colorscheme monokai

" Set default fonts
set guifont="Inconsolata-dz for Powerline":h12

" Smartcase for search (if has uppercase letters = case sensitive)
set ignorecase
set smartcase

" mouse support
set mouse=a

" Indicate that last window have a statusline too (support for airline)
set laststatus=2

" no beep
set visualbell

" Disable wrapping long string
set nowrap

" Numbers of rows to keep to the left and to the right off the screen
set scrolloff=10

" Numbers of columns to keep to the left and to the right off the screen
set sidescrolloff=10

" set window size
if has ("gui_running")
    set lines=50 columns=120
endif

" show column on 80 symbols
if (exists('+colorcolumn'))
    set colorcolumn=80
    highlight ColorColumn ctermbg=9
endif

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>

" -- sudo save
cmap w!! w !sudo tee >/dev/null %

" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,trail:·,eol:¬,nbsp:_

" show line numbers
set number

" show command in bottom bar
set showcmd

" highlight current line
set cursorline

" redraw only when we need to.
set lazyredraw

" set history to the 100 instead of 12
set history=100

" ******************** "
" Tabs
"

" Copy indent from previous line
set autoindent

" Enable smart indent. it add additional indents whe necessary
set smartindent

" Replace tabs with spaces
set expandtab

" Whe you hit tab at start of line, indent added according to shiftwidth value
set smarttab

" number of spaces to use for each step of indent
set shiftwidth=4

" Number of spaces that a Tab in the file counts for
set tabstop=4

" Same but for editing operation (not shure what exactly does it means)
" but in most cases tabstop and softtabstop better be the same
set softtabstop=4

" Round indent to multiple of 'shiftwidth'.
" Indentation always be multiple of shiftwidth
" Applies to  < and > command
set shiftround

" ******************** "
" Wildmenu
"

" visual autocomplete for command menu
set wildmenu

" Autocmpletion hotkey
set wildcharm=<TAB>

" ******************** "
" Searching
"

" search as characters are entered
set incsearch

" Show matching brackets
set showmatch

" Make < and > match as well
set matchpairs+=<:>

" ******************** "
" Folding
"
"
" No fold closed at open file
set foldlevelstart=99
set nofoldenable

" Enable syntax folding in javascript
let javaScript_fold=1

" Keymap to toggle folds with space
nmap <space> za

" ******************** "
" Backups
"

" Disable backups file
set nobackup

" Disable vim common sequense for saving.
" By defalut vim write buffer to a new file, then delete original file
" then rename the new file.
set nowritebackup

" Disable swp files
set noswapfile

" ******************** "
" Edit
"

" Allow backspace to remove indents, newlines and old text
set backspace=indent,eol,start

" Add '-' as recognized word symbol. e.g dw delete all 'foo-bar' instead just 'foo'
set iskeyword+=-

" Ctrl+a and Ctrl+x should support alpha (a,b,c) and hex (0x001) inc/decr
" This turn off octal mode (007 -> 010 on Ctrl+a)
set nrformats=alpha,hex

" ******************** "
" Diff Options
"

" Display filler
set diffopt=filler

" Open diff in horizontal buffer
set diffopt+=horizontal

" Ignore changes in whitespaces characters
set diffopt+=iwhite

" ******************** "
" Custom file settings
"

augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab

    " For bash 2 is good for tabs
    autocmd BufEnter,BufNewFile *.sh setlocal tabstop=2
    autocmd BufEnter,BufNewFile *.sh setlocal shiftwidth=2
    autocmd BufEnter,BufNewFile *.sh setlocal softtabstop=2

    autocmd BufRead,BufNewFile *.json set ft=json

    " Add spell checker for markdown files
    autocmd FileType markdown setlocal spell

    " Wrap lines for markdown as it is text
    autocmd FileType markdown set wrap linebreak nolist

    " Disable vertical line at max string length in NERDTree
    autocmd FileType nerdtree setlocal colorcolumn=""

    " Enable Folding, uses plugin vim-javascript-syntax
    autocmd FileType javascript* call JavaScriptFold()

    " Wrap for markdown as it is text
    autocmd FileType gitcommit set wrap linebreak nolist
    autocmd FileType gitcommit setlocal textwidth=0
    autocmd FileType gitcommit setlocal spell
augroup END

" ----------------------
"  Plugins
" ----------------------

" ******************** "
" NERDTree
"

" Tell NERDTree to display hidden files on startup
let NERDTreeShowHidden=1

" Disable bookmarks label, and hint about '?'
let NERDTreeMinimalUI=1

" Display current file in the NERDTree ont the left
nmap <silent> <leader>f :NERDTreeFind<CR>

" Toggle nerd tree on the left
map <C-n> :NERDTreeToggle<CR>


" ******************** "
" ctrlp
"

" Open ctrlp in the same window as nerdtree
let g:ctrlp_dont_split = 'nerdtree'

" No limits
:let g:ctrlp_max_files=0

" Ignore path from git/hg and svn
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn)$'
    \ }

" The maximum depth of a directory tree to recurse into
let g:ctrlp_max_depth = 40

" Use ctrlp-py-matcher for faster search
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

" disable automatically changing working path
let g:ctrlp_working_path_mode = ''

" custom commands to get all files for ctrlp
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'cd %s && git ls-files --cached --others --exclude-standard'],
    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
    \ },
  \ 'fallback': 'find %s -type f'
  \ }

" ******************** "
" Syntastic
"

" Enable autochecks
let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1

" Change icons
let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "⚠"

" Don't run on :wq
let g:syntastic_check_on_wq = 0

" check json files with jshint
let g:syntastic_filetype_map = { "json": "javascript", }

" For correct works of next/previous error navigation
let g:syntastic_always_populate_loc_list = 1

" Enable tslint and compiler check for TypeScript
let g:syntastic_typescript_checkers = ['tslint', 'tsc']

" For go we only want to use format (build is slow)
let g:syntastic_go_checkers = [ 'gofmt' ]

" C/C++
let g:syntastic_cpp_checkers = [ ]
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = '-Wall -Wextra -Werror'
let g:syntastic_c_checkers = [ ]
let g:syntastic_c_compiler = 'clang++'
let g:syntastic_c_compiler_options = '-Wall -Wextra -Werror'

" ******************** "
" DelimitMate
"

" Delimitmate place cursor correctly n multiline objects e.g.
" if you press enter in {} cursor still be
" in the middle line instead of the last
let delimitMate_expand_cr = 1

" Delimitmate place cursor correctly in singleline pairs e.g.
" if x - cursor if you press space in {x} result will be { x } instead of { x}
let delimitMate_expand_space = 1

" ******************** "
" vim-airline
"

" Colorscheme for airline
let g:airline_theme='understated'

" Enable airline for tab-bar
let g:airline#extensions#tabline#enabled = 1

" Use airline powerline fonts for symbols
let g:airline_powerline_fonts = 1

" ******************** "
" vim-markdown
"

" markdown plugin configuration
let g:vim_markdown_frontmatter=1

" ******************** "
" json
"

" json plugin, don't conceal
let g:vim_json_syntax_conceal = 0

" ********************* "
" go with tagbar
"

" See https://github.com/jstemmer/gotags
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

" *********************** "
" pymode
"

" Annoying feature
let g:pymode_rope_complete_on_dot = 0
```

As you can see I use [vundle](https://github.com/VundleVim/Vundle.Vim) for plugins.
*Oh-my-Zsh* also has plugin for vundle, it allows to run `vundle-update` to update all plugins.

Link to my [vim cheatsheet]({{site.url}}/cheatsheets/vim/).
