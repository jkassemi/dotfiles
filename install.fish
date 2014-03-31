#!/usr/local/bin/fish

for installer in **/install.fish
  set target (dirname $installer)
  cd $target
  fish < ./install.fish
  cd ..
end
