#!/bin/bash

SCRIPT=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`
SCRIPTPATH=`dirname $SCRIPT`
PROFILE=$HOME/.bashrc
OHMYZSH=$HOME/.oh-my-zsh
ZSHRC=$HOME/.zshrc

OS=$(uname)

# Install a package using the right package manager for the current OS.
# Mac uses Homebrew; Ubuntu/Debian uses apt. Skips silently on unknown OS.
install_package() {
  local pkg=$1
  case "$OS" in
    Darwin) brew install "$pkg" ;;
    Linux)  sudo apt-get install -y "$pkg" ;;
    *) echo "Unknown OS '$OS' — skipping install of $pkg" ;;
  esac
}

HELP="
Usage:
  $0 all        # Install all the things
  $0 all -tmux  # Everything but Tmux
  $0 +tmux      # Just install Tmux

Description:
  Wire in everything needed for my home directory. If parameters are
  included, only wire in specific sections.

Options:
  --profile path, -p path
    The profile file to append to. (Default: $PROFILE)

Components:
  Specific components can be turned on or off with a +/- prefix.

  ack      Ack config
  agentos  Agent OS
  bash     Bash extras
  brew     Homebrew
  bin      Bin files
  git      Git config
  irb      IRB completion and other goodies
  jshint   JSHint config
  node     Install the latest node
  rake     Rake completion
  screen   Screen config
  tmux     Tmux and Tmuxinator config
  vim      Vim config and plugins
  zsh      Zshell extras

"
case $# in 0) echo "$HELP"; exit 0;; esac

# Parse options
while true
do
  case $# in 0) break;; esac
  case $1 in
    --profile|-p)
      shift;
      PROFILE=$1
      ;;

    all)
      ack=true;
      bash=true;
      bin=true;
      brew=true;
      git=true;
      irb=true;
      jshint=true;
      node=true;
      rake=true;
      screen=true;
      tmux=true;
      vim=true;
      zsh=true;
      agentOS=true;
      ;;

    +ack) ack=true;;
    -ack) ack=false;;

    +bash) bash=true;;
    -bash) bash=false;;

    +brew) brew=true;;
    -brew) brew=false;;

    +git) git=true;;
    -git) git=false;;

    +irb) irb=true;;
    -irb) irb=false;;

    +jshint) jshint=true;;
    -jshint) jshint=false;;

    +node) node=true;;
    -node) node=false;;

    +rake) rake=true;;
    -rake) rake=false;;

    +screen) screen=true;;
    -screen) screen=false;;

    +tmux) tmux=true;;
    -tmux) tmux=false;;

    +vim) vim=true;;
    -vim) vim=false;;

    +zsh) zsh=true;;
    -zsh) zsh=false;;

    +bin) bin=true;;
    -bin) bin=true;;

    +agentos) agentOS=true;;
    -agentos) agentOS=true;;

    help) echo "$HELP"; exit 0 ;;

    *) echo; echo "Invalid option $1."; echo "$HELP"; exit 2 ;;
  esac
  shift
done

if [ "$git" = true ]; then
  #######################
  echo "Git"
  #######################

  update_profile=true

  # A couple of things for Git that we want to be user global. Note that we
  # should NOT link .git and .gitmodules as these belong to this project and are
  # not intended to be in my user directory.
  ln -sfv $SCRIPTPATH/.gitconfig $HOME/.gitconfig
  ln -sfv $SCRIPTPATH/.gitignore $HOME/.gitignore
  ln -sfv $SCRIPTPATH/.gitusers $HOME/.gitusers

  ln -sfv $SCRIPTPATH/.git-completion $HOME/.git-completion

  echo ""
fi

if [ "$brew" = true ]; then
  #######################
  echo "Homebrew"
  #######################

  if [[ "$OS" == "Darwin" ]]; then
    if [[ ! -d /opt/homebrew/Cellar ]] && [[ ! -d /usr/local/Cellar ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  else
    echo "Skipping Homebrew on $OS (using apt instead)"
  fi

  echo ""
fi

if [ "$node" = true ]; then
  #######################
  echo "Node"
  #######################

  # coc.nvim installs its extensions in a worker thread, where the global Web
  # Crypto `crypto` object is undefined until Node 20 (it exists only on the
  # main thread in Node 18). Ubuntu's apt ships Node 18, so coc-tsserver fails
  # to install with "ReferenceError: crypto is not defined". We install the
  # current LTS (Node 24) and require at least the version that fixes this.
  NODE_LTS_MAJOR=24
  NODE_MIN_MAJOR=20

  node_major() {
    command -v node >/dev/null 2>&1 || { echo 0; return; }
    node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0
  }

  if [ "$(node_major)" -lt "$NODE_MIN_MAJOR" ]; then
    case "$OS" in
      Darwin)
        # Homebrew's node formula tracks current LTS.
        brew install node
        ;;
      Linux)
        # apt's nodejs is too old; pull the current Node LTS from NodeSource.
        curl -fsSL "https://deb.nodesource.com/setup_${NODE_LTS_MAJOR}.x" | sudo -E bash -
        sudo apt-get install -y nodejs
        ;;
      *)
        echo "Unknown OS '$OS' — please install Node >= $NODE_MIN_MAJOR manually"
        ;;
    esac
  else
    echo "Node $(node --version) already satisfies >= $NODE_MIN_MAJOR — skipping"
  fi

  # On Ubuntu, apt's nodejs ships npm separately; NodeSource bundles it.
  if [[ "$OS" == "Linux" ]] && ! command -v npm >/dev/null 2>&1; then
    install_package npm
  fi
fi

if [ "$vim" = true ]; then
  #######################
  echo "Vim"

  install_package neovim

  ln -sfnv $SCRIPTPATH/.vim $HOME/.vim
  ln -sfv $SCRIPTPATH/.vimrc $HOME/.vimrc
  ln -sfv $SCRIPTPATH/.gvimrc $HOME/.gvimrc
  mkdir -p $SCRIPTPATH/.vim-tmp

  # Neovim reads ~/.config/nvim/, not ~/.vim/ or ~/.vimrc — bridge it.
  mkdir -p $HOME/.config/nvim
  ln -sfv $SCRIPTPATH/.config/nvim/init.vim $HOME/.config/nvim/init.vim
  ln -sfv $SCRIPTPATH/.vim/coc-settings.json $HOME/.config/nvim/coc-settings.json

  # Install plugins. Prefer nvim since the .aliases file points vi/vim at it.
  if command -v nvim >/dev/null 2>&1; then
    nvim +PlugInstall +qall
  elif command -v vim >/dev/null 2>&1; then
    vim +PlugInstall +qall
  fi

  echo ""
fi

if [ "$screen" = true ]; then
  #######################
  echo "Screen"
  #######################

  ln -sfv $SCRIPTPATH/.screenrc $HOME/.screenrc

  echo ""
fi

if [ "$tmux" = true ]; then
  #######################
  echo "tmux"
  #######################

  update_profile=true

  install_package tmuxinator
  # reattach-to-user-namespace exists only on macOS (clipboard integration).
  # On Linux, the tmux config uses xclip for the system clipboard.
  if [[ "$OS" == "Darwin" ]]; then
    install_package reattach-to-user-namespace
  else
    install_package xclip
  fi

  ln -sfv $SCRIPTPATH/.tmux.conf $HOME/.tmux.conf
  ln -sfnv $SCRIPTPATH/tmuxinator $HOME/.tmuxinator

  ln -sfv $SCRIPTPATH/.tmux-completion $HOME/.tmux-completion
  ln -sfv $SCRIPTPATH/.tmuxinator-completion $HOME/.tmuxinator-completion

  echo ""
fi

if [ "$ack" = true ]; then
  #######################
  echo "ACK"
  #######################

  ln -sfv $SCRIPTPATH/.ackrc $HOME/.ackrc

  echo ""
fi

if [ "$irb" = true ]; then
  #######################
  echo "IRB"
  #######################

  ln -sfv $SCRIPTPATH/.irbrc $HOME/.irbrc

  echo ""
fi

if [ "$rake" = true ]; then
  #######################
  echo "Rake"
  #######################

  update_profile=true

  mkdir $HOME/lib
  ln -sfv $SCRIPTPATH/lib/rake-complete.rb $HOME/lib/rake-complete.rb

  echo ""
fi

if [ "$jshint" = true ]; then
  #######################
  echo "JSHint"
  #######################

  # On Ubuntu, apt-installed npm needs root for global installs.
  if [[ "$OS" == "Linux" ]]; then
    sudo npm install -g jshint
  else
    npm install -g jshint
  fi
  ln -sfv $SCRIPTPATH/.jshintrc $HOME/.jshintrc

  echo ""
fi

add_to_profile() {
  local line=$1
  touch $PROFILE
  if ! grep -q "$line" $PROFILE; then
    echo "  $line"
    eval $(echo "$line" | tee -a $PROFILE)
  fi
}

if [ "$bash" = true ]; then
  #######################
  echo "Bash Extras"
  #######################

  update_profile=true

  ln -sfv $SCRIPTPATH/.prompt $HOME/.prompt
  ln -sfv $SCRIPTPATH/.exports $HOME/.exports
  ln -sfv $SCRIPTPATH/.aliases $HOME/.aliases
  ln -sfv $SCRIPTPATH/.projects $HOME/.projects
  if [[ "$OS" == "Darwin" ]]; then
    ln -sfv $SCRIPTPATH/.brew-completion $HOME/.brew-completion
  fi

  echo ""
fi

add_to_zshrc() {
  local line=$1
  touch $ZSHRC
  if ! grep -q "$line" $ZSHRC; then
    echo "  $line"
    eval $(echo "$line" | tee -a $ZSHRC)
  fi
}

if [ "$zsh" = true ]; then
  #######################
  echo "Zshell Extras"
  #######################

  update_zshrc=true

  if ! command -v zsh >/dev/null 2>&1; then
    install_package zsh
  fi

  if [[ ! -d "$OHMYZSH" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # Make zsh the default login shell if it isn't already.
  zsh_path=$(command -v zsh)
  if [ -n "$zsh_path" ] && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo "Changing default shell to $zsh_path (you may be prompted for your password)..."
    chsh -s "$zsh_path"
  fi

  echo ""
fi

if [ "$bin" = true ]; then
  #######################
  echo "Bin files"
  #######################

  ln -sfnv $SCRIPTPATH/bin $HOME/bin
fi

if [ "$update_profile" = true ]; then
  echo ""
  echo "Adding the following lines to your profile ($PROFILE):"
  echo ""

  if [ "$bash" = true ]; then
    add_to_profile 'source ~/.prompt'
    add_to_profile 'source ~/.exports'
    add_to_profile 'source ~/.aliases'
    add_to_profile 'source ~/.projects'
  fi

  if [ "$git" = true ]; then
    add_to_profile 'source ~/.git-completion'
  fi

  if [ "$tmux" = true ]; then
    add_to_profile 'source ~/.tmux-completion'
    add_to_profile 'source ~/.tmuxinator-completion'
  fi

  if [ "$rake" = true ]; then
    add_to_profile 'complete -C path/to/tilde/lib/rake-complete.rb -o default rake'
  fi

  if [[ "$OS" == "Darwin" ]]; then
    add_to_profile 'source ~/.brew-completion'
  fi
fi

if [ "$update_zshrc" = true ]; then
  echo ""
  echo "Adding the following lines to your zshrc ($ZSHRC):"
  echo ""

  if [ "$zsh" = true ]; then
    add_to_zshrc 'source ~/.aliases'
    add_to_zshrc 'source ~/.projects'
  fi
fi

echo ""


if [ "$agentOS" = true ]; then
  #######################
  echo "Agent OS"
  #######################

  ln -sfnv $SCRIPTPATH/.agent-os $HOME/.agent-os

  echo ""
fi
