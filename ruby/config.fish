set -xg RUBY_HEAP_MIN_SLOTS 800000
set -xg RUBY_HEAP_FREE_MIN 100000
set -xg RUBY_HEAP_SLOTS_INCREMENT 300000
set -xg RUBY_HEAP_SLOTS_GROWTH_FACTOR 1
set -xg RUBY_GC_MALLOC_LIMIT 79000000

source /usr/local/share/chruby/chruby.fish
source /usr/local/share/chruby/auto.fish
