fast-yesod-devel
================

Small haskell command line programm to speed up yesod reload. In the spirit of https://gist.github.com/maerten/2c9152f68e2bbefa93ac


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
