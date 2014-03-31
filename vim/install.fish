cp -R vim/ ~/.vim
cp vimrc ~/.vimrc
mkdir -p ~/.vim/bundle

# Believe this is entirely unnecessary, since vundle
# manages these on 
if test -e ~/.vim/bundle/vundle
else
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
end

vim +PluginInstall +qall

if test -e ~/.vim/go.vim
else
  git clone https://github.com/fsouza/go.vim ~/.vim/go.vim
end
