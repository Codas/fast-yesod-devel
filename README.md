fast-yesod-devel
================

Small haskell command line programm to speed up yesod reload. In the spirit of https://gist.github.com/maerten/2c9152f68e2bbefa93ac

# Current state
This is still more or less experimental. That said, this script should not eat
your pet or start a nuclear war. If it does, feel free to send a pull request.

It does has a fairly high CPU utilization (20% of one core on my MacBook
Pro). If anyone knows why that might be, please help?

# Install
Just combine the binary. Either globally:
```
cabal install
```

or locally in a sandbox:
```
cabal sandbox init
cabal install
cp dist/build/yesod-fast-devel/yesod-fast-devel  [somewhere in your PATH]
```

Then just run inside a yesod application with
```
yesod-fast-devel
```

This is not tested under Linux or Windows, just OS X. It should work on all
theses systems though.


# Why not just use `yesod devel` or `DevelMain.hs`?
Because yesod devel takes longer to reload applications and DevelMain has no
autoreload feature.
I could just modify DevelMain.hs, but then I had to modify every single
scaffold, an external binary is simply more convenient.
