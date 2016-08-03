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

if test -e ~/.vim/bundle/vim-ruby
else
  git clone https://github.com/vim-ruby/vim-ruby.git ~/.vim/bundle/vim-ruby
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

# Install trailing whitespace highlighter
if test -e ~/.vim/bundle/vim-better-whitespace
else
  git clone git://github.com/ntpeters/vim-better-whitespace.git ~/.vim/bundle/vim-better-whitespace
end

# Install tabular
if test -e ~/.vim/bundle/tabular
else
  git clone git://github.com/godlygeek/tabular.git ~/.vim/bundle/tabular
end

# Install vimgutter
if test -e ~/.vim/bundle/vim-gitgutter
else
  git clone git://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter
end


#
vim +PluginInstall +qall
