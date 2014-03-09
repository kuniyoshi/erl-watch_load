NAME
====

watch_load

USAGE
=====

``` erlang
  > watch_load:start_loop()
```

DESCRIPTION
===========

This module watches a directory to load.
If the beam file in the directory is changed,
then load the new beam.

HOW TO USE
==========

Copy This Repository to Your Home
---------------------------------

``` zsh
  % git clone git://github.com/kuniyoshi/erl-watch_load.git
  % make -C watch_load
```

Write Your Dot Erlang File
--------------------------

``` zsh
  % echo <<END_WATCH_LOAD >>~/.erlang
case os:getenv("ERL_WATCH_LOAD") of
    "1" ->
        Filename = filename:join(os:getenv("HOME"), "watch_load/ebin/watch_load"),
        {module, watch_load} = code:load_abs(Filename),
        ok = watch_load:start_loop();
    false ->
        ok
end.
END_WATCH_LOAD
```

Develop Your Module with No `l(example)`
----------------------------------------

``` zsh
  % ERL_WATCH_LOAD=1 erl -pa ebin
```
