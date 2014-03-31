if test -e ~/.oh-my-fish
else
  git clone git://github.com/bpinto/oh-my-fish.git ~/.oh-my-fish
end

grep -q '^/usr/local/bin/fish$' /etc/shells; or echo '/usr/local/bin/fish' | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish

mkdir -p ~/.config/fish
mkdir -p ~/.config/fish/load

cp config.fish ~/.config/fish/config.fish
