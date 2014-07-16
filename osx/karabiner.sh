#!/bin/sh

cli=/Applications/Karabiner.app/Contents/Library/bin/karabiner

$cli set repeat.wait 25
/bin/echo -n .
$cli set repeat.initial_wait 200
/bin/echo -n .
$cli set remap.simple_vi_mode 1
/bin/echo -n .
$cli set option.tabmode_hl 1
/bin/echo -n .
$cli set remap.tabmode 1
/bin/echo -n .
$cli set option.tabmode_leftright 1
/bin/echo -n .
/bin/echo
