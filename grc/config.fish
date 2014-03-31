# @skivvies (https://github.com/fish-shell/fish-shell/issues/586)
# (https://github.com/Homebrew/homebrew/blob/master/Library/Formula/grc.rb#L22)
set GRC (which grc)
if test $TERM != "dumb" -a -n $GRC
  alias colourify="$GRC -es --colour=auto"
  alias configure='colourify ./configure'
  alias diff='colourify diff'
  alias make='colourify make'
  alias gcc='colourify gcc'
  alias g++='colourify g++'
  alias as='colourify as'
  alias gas='colourify gas'
  alias ld='colourify ld'
  alias netstat='colourify netstat'
  alias ping='colourify ping'
  alias traceroute='colourify /usr/sbin/traceroute'
end
