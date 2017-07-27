#!/bin/bash

pick_scl_ruby() {
    # select the first suitable installed ruby scl version. Edit this
    # to be more specific if needed.
    scl --list | grep 'rh-ruby2[234]' | head -n1
}

SCL_RUBY=""
if ruby --version | grep --extended-regexp --quiet '^ruby +2\.0\.0'
then
  SCL_RUBY="$(pick_scl_ruby)"
fi

# If we can't find a newer ruby then just try the old one anyway.
if [[ -n "${SCL_RUBY}" ]]
then
  source scl_source enable "${SCL_RUBY}"
fi

# ruby --version
exec ruby "$@"
