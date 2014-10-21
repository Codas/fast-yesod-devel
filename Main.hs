module Main where

import System.FSNotify
import System.IO
import System.Process
import Control.Concurrent (threadDelay, forkIO)
import Control.Monad.STM (atomically)
import Control.Concurrent.STM.TChan
import Control.Monad (forever)
import Filesystem.Path.CurrentOS (toText, filename)
import Data.Text (isInfixOf)
import Debug.Trace
import Control.Exception (bracket)

main :: IO ()
main =
  do chan <- atomically newTChan
     _ <- forkIO $ watchThread chan
     replThread chan
     return ()

watchThread :: TChan Event -> IO ()
watchThread writeChan = withManager (\mgr ->
  do -- start a watching job (in the background)
     _ <- watchTree mgr          -- manager
                    "."          -- directory to watch
                    shouldReload -- predicate
                    (reloadApplication writeChan)        -- action
     -- sleep forever (until interrupted)
     forever $ threadDelay 1000000000)

replThread :: TChan Event -> IO ()
replThread chan =
  do readChan <- atomically (dupTChan chan)
     bracket newRepl
             (\(_, _, _, process) -> do interruptProcessGroupOf process
                                        threadDelay 200000
                                        terminateProcess process
                                        waitForProcess process)
             (\(Just replIn, _, _, process) ->
               do hSetBuffering replIn LineBuffering
                  threadDelay 1000000
                  hPutStrLn replIn loadString
                  hPutStrLn replIn "import Network.Wai.Handler.Warp"
                  hPutStrLn replIn startString
                  forever (do event <- atomically (readTChan readChan)
                              print event
                              interruptProcessGroupOf process
                              hPutStrLn replIn loadString
                              hPutStrLn replIn startString))
  where startString = "getApplicationDev >>= \\(port, app) -> runSettings (setPort port defaultSettings) app"
        loadString = ":load Application"

wtf :: Show a1 => a -> a1 -> a
wtf v x = trace (show x) v

shouldReload :: Event -> Bool
shouldReload event = not (foldr (||) False conditions)
  where fp = case event of
              Added filePath _ -> filePath
              Modified filePath _ -> filePath
              Removed filePath _ -> filePath
        p = case (toText fp) of
              Left filePath -> filePath
              Right filePath -> filePath
        fn = case (toText (filename fp)) of
                Left filePath -> filePath
                Right filePath -> filePath
        conditions = [ notInPath ".git", notInPath "yesod-devel", notInPath "dist"
                     , notInFile "#", notInPath ".cabal-sandbox"]
        notInPath t = t `isInfixOf` p
        notInFile t = t `isInfixOf` fn

reloadApplication :: TChan Event -> Event -> IO ()
reloadApplication chan event = atomically (writeTChan chan event)

newRepl :: IO (Maybe Handle, Maybe Handle, Maybe Handle, ProcessHandle)
newRepl = createProcess (newProc "cabal" ["repl"])

newProc :: FilePath -> [String] -> CreateProcess
newProc cmd args = CreateProcess {cmdspec = RawCommand cmd args
                                 ,cwd = Nothing
                                 ,env = Nothing
                                 ,std_in = CreatePipe
                                 ,std_out = Inherit
                                 ,std_err = Inherit
                                 ,close_fds = False
                                 ,create_group = True
                                 ,delegate_ctlc = False}
