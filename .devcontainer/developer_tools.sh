#!/bin/bash

###  Setup script to run after codespaces dev container built.
###  Should be run as a postCreateCommand via the devcontainer.json file
###  Dotfiles cloning should not run via github settings, will be run here.
###  Assumes will run as vscode user so home will be home for that user
### Assumes devcontainer.json is calling this script via bash -i aka interactive mode

echo "Installing Developer Requirements"
# make aliases expand and work in the script
shopt -s expand_aliases

# echo the workspace path and save as an environment variable
echo "Devcontainer workspace path is $PWD"
export DEVCONTAINER_WORKSPACE_PATH=$PWD

#  Go to home directory for user
cd ~ || exit

# two branches of dotfiles install, whether SSH_KEY_GITHUB exists or not
# that will exist if this is a codespace, so we will assume devcontainer.json is configured
# to provide access to the repo as well
# setup dotfiles management
#if [[ -z ${SSH_KEY_GITHUB:-default} ]]; then
if [[ -v SSH_KEY_GITHUB ]] || [[ -v GITHUB_TOKEN ]]; then
  # assumes .cfg is already in .gitignore, if not needs to be to avoid recursion problems
  #don't need this, git clone creates .cfg directory
  #git init --bare "$HOME"/.cfg
  # clone the dotfiles repository as a bare repository
  gh repo clone broander/dotfiles "$HOME"/.cfg -- --bare
else
  # if variable is not present, generate github ssh key
  # and provide it to the user to add to github
  mkdir -p ~/.ssh
  echo "Creating github ssh token.  When prompted, name it 'github'"
  cd ~/.ssh || exit
  ssh-keygen -t ed25519 -C "jason@broander.me"
  # now prompt user for ssh public token for github
  echo "Please copy this public SSH token to your github profile's SSH keys"
  less github.pub
  cd ~ || exit
  # add ssh key to agent
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/github
  # now clone repository
  git clone --bare git@github.com:broander/dotfiles.git "$HOME"/.cfg
fi

# done with branching install, proceed with rest of process to set up dotfiles
# alias is also defined in bashrc, but need it here for the script to work
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
# stash any conflicting dotfiles so can checkout files from repo
config stash
config checkout
# copy good git config file for this repo so easy to commit config changes for dotfiles
cp ~/.setup_config/backup-git-.cfg-config ~/.cfg/config

# copy the github codespace ssh secret that's already configured in github
# this will allow the 'config' git commands to work with the dotfiles repo
# remember for this to work, the codespace has to be added to the list of repos
# with access to the SSH_KEY_GITHUB codespace secret
if [[ -v SSH_KEY_GITHUB ]] || [[ -v GITHUB_TOKEN ]]; then
  if [[ -v SSH_KEY_GITHUB ]]; then
	  echo "Copying github codespace ssh secret to ~/.ssh/github"
	  mkdir -p ~/.ssh
	  echo "$SSH_KEY_GITHUB" >~/.ssh/github
	  chmod 600 ~/.ssh/github
  else
    echo "SSH_KEY_GITHUB not found; check if you've given the codespace access to the secret in Github"
  fi
else
  # prompt user to log into github CLI
  gh auth login
fi

# clone the standard-dev-container repo so easier to push changes to it if needed
mkdir -p ~/Github
mkdir -p ~/Github/BuildClones
cd ~/Github
if [[ -v SSH_KEY_GITHUB ]] || [[ -v GITHUB_TOKEN ]]; then
  gh repo clone broander/standard-dev-container ~/Github/standard-dev-container
else
  git clone git@github.com:broander/standard-dev-container.git
fi
cd ~ || exit

# add conda init info for shells
conda init
conda init fish
conda init zsh

# # Install powerline
# pip install --user powerline-status

# # update ipython and powerline so it works with ipython
# pip install ipython --upgrade
# pip install ipdb  # for better debugging
# pip install prompt_toolkit --upgrade
# pip install pygments --upgrade
# pip install git+https://github.com/powerline/powerline.git@develop

# Install TMUX Plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/scripts/install_plugins.sh

# Update fish to the latest version
# Test if Debian 11
if lsb_release -i | grep -q Debian && lsb_release -d | grep -q 11; then
  echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
  curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg >/dev/null
  sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install fish
fi
# Test if Ubuntu
if lsb_release -i | grep -q Ubuntu; then
  sudo apt-add-repository ppa:fish-shell/release-3
  sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install fish
fi

# Install ohmyfish, and bobthefish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install >install
fish install --noninteractive --path=~/.local/share/omf --config=~/.config/omf
fish omf install bobthefish
# remove installer file
cd ~ || exit
rm install

# Install latest version of VIM # not working with miniconda python10...
# mkdir -p ~/Github
# mkdir -p ~/Github/BuildClones
# cd ~/Github/BuildClones || exit
# git clone https://github.com/vim/vim.git
# cd vim || exit
# cd src || exit
# # uses customized makefile per vim customization instructions
# #rm Makefile
# #cp ~/.setup_config/vim-Makefile ./Makefile
# sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install git make clang libtool-bin libpython3-dev
# ./configure --enable-python3interp --disable-gui --without-x --with-python3-command=/usr/bin/python3
# # if want clipboard enabled, install these dependencies as well and run this config command instead:
#sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install dbus-x11 libx11-dev xserver-xorg-dev xorg-dev
#./configure --enable-python3interp --enable-gui=no --with-python3-command=/usr/bin/python3
# # make reconfig
# make
# sudo make install
# cd ~ || exit

# install vim with conda-forge instead
# assumes mamba is already installed via the Docker image
#conda install -n base -c conda-forge -y mamba
#mamba update -n base -y mamba
#mamba update -n base -y conda
#mamba install -n base -c conda-forge -y vim
#mamba update -n base -c conda-forge -y ncurses

# Vundle for VIM
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
#git clone https://github.com/vim-scripts/vundle.git ~/.vim/bundle/Vundle.vim
#git clone https://github.com/Kernelily/Vundle ~/.vim/bundle/Vundle.vim # backup of vundle repo for use while it's down
# Install VIM plugins specified in .vimrc
#vim +PlugInstall +qall
vim --clean '+source ~/.vimrc' +PluginInstall +qall

# Install vim-language-server, which requires NPM
sudo npm install -g vim-language-server

# install YTOP system performance tool; requires rust
# install rust first
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
# not being maintained, trying alternative below
# ./.cargo/bin/cargo install ytop
# install btm
rustup update stable
# install with rust
# cargo install bottom --locked
## install deb package, less to download
# curl -LO https://github.com/ClementTsang/bottom/archive/0.10.2.tar.gz
# sudo dpkg -i bottom_0.8.0_amd64.deb
# rm bottom_0.8.0_amd64.deb
# install archived package, less to download
curl -LO https://github.com/ClementTsang/bottom/archive/0.10.2.tar.gz
tar -xzvf 0.10.2.tar.gz
cargo install --path . --locked
rm -r bottom-0.10.2
rm 0.10.2.tar.gz

# Install Universal Ctags
mkdir -p ~/Github/BuildClones
cd ~ || exit
cd Github || exit
cd BuildClones || exit
git clone https://github.com/universal-ctags/ctags.git
cd ctags || exit
./autogen.sh
./configure #--prefix=/where/you/want # defaults to /usr/local./configure
make
sudo make install
cd ~ || exit

# # YouCompleteMe language completer for VIM
python3 ~/.vim/bundle/YouCompleteMe/install.py --clangd-completer

# Install latest version of Mosh
# Start by installing prerequisites (assumes Debian or Ubuntu)
# sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && sudo apt-get -y install build-essential \
#     protobuf-compiler libprotobuf-dev pkg-config libutempter-dev zlib1g-dev libncurses5-dev \
#     libssl-dev bash-completion tmux less
# mkdir -p ~/Github/BuildClones
# cd ~/Github/BuildClones || exit
# git clone https://github.com/mobile-shell/mosh.git
# cd mosh || exit
# ./autogen.sh
# ./configure
# make
# sudo make install
# cd ~ || exit

# install additional conda env stuff
eval "$DEVCONTAINER_WORKSPACE_PATH/.devcontainer/conda-env-setup.sh"

# set up for this project
# input the desired env name that was set up in the dockerfile or conda-env-setup.sh
# and this will ensure it is automatically activated by the shells when logging
# in.
# Can also specify additional startup code to be added for .profile or
# .bashrc here.

project_env_input_name="project_env_name"

# add to .profile
# echo '
# 	project_env_name='"$project_env_input_name"'
# 	# startup automation for this project, added by developer_tools.sh for this
# 	# dev container.  Added to top of profile so runs before .bashrc
#	if [ -x "$(command -v /opt/conda/bin/conda)" ]; then
# 		if conda env list | grep -q "$project_env_name"; then
# 			#echo "environment exists, saving as env variable"
# 			export PROJECT_ENV_NAME="$project_env_name"
#		else
#			:
# 			#echo "$project_env_name environment does not exit"
# 		fi
#	fi
# ' | cat - ~/.profile >temp && mv temp ~/.profile

# add to .bashrc
# echo '
# 	# startup automation for this project, added by developer_tools.sh for this
# 	# dev container
# 	<<CODE GOES HERE>>
#	if [[ -v PROJECT_ENV_NAME ]]; then
#		#echo "Setting up tmux for project $PROJECT_ENV_NAME"
#		source ~/bin/tm-setup.sh "$PROJECT_ENV_NAME"
#	else
#		source ~/bin/tm-setup.sh
#	fi
# ' >>~/.bashrc

echo "Developer Requirements Installation Completed"
sleep 3

exit
