if which grc
  # We've got it, no need to install 
else
  brew install grc 
end

cp config.fish ~/.config/fish/load/grc.fish
