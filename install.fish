#!/usr/local/bin/fish

# Install fish
cd fish
fish < ./bootstrap.fish
cd ..

# Install everything else
for installer in **/install.fish
  set target (dirname $installer)
  cd $target
  fish < ./install.fish
  cd ..
end
