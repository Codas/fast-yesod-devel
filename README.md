fast-yesod-devel
================

Small haskell command line programm to speed up yesod reload. In the spirit of https://gist.github.com/maerten/2c9152f68e2bbefa93ac

# State
This is by far not ready for anything at the moment and some of the unterlying assumtpions are plain wrong.
A rewrite based on yesods scaffolding DevelMain.hs is probably in order.

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

This is not tested under Linux or Windows, just OS X
