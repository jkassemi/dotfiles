brew install vim

cp -R vim/ ~/.vim
cp vimrc ~/.vimrc
mkdir -p ~/.vim/bundle

##

# Vundle
if test -e ~/.vim/bundle/vundle
else
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
end

# Install vim-go
# http://blog.gopheracademy.com/vimgo-development-environment
cd ~/.vim/bundle

if test -e vim-go
else
  git clone https://github.com/fatih/vim-go.git
end

if test -e YouCompleteMe
else
  git clone https://github.com/Valloric/YouCompleteMe.git
end

cd YouCompleteMe
git submodule update --init --recursive
./install.sh

##
vim +PluginInstall +qall
