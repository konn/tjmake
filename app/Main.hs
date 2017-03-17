module Main where

import Data.Maybe                 (fromMaybe)
import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Util

main :: IO ()
main = shakeArgs shakeOptions{ shakeFiles = "." } $ do
  phony "clean" $ do
    putNormal "Cleaning files in */*.lp{o,} ..."
    removeFilesAfter "." ["//*.lp", "//*.lpo", "//*.mf"]

  "//*.lpo" %> \out -> do
    processTjDepend out
    cmd "tjcc" (dropExtension out)

  "//*.lp" %> \out -> do
    processTjDepend out
    cmd "tjlink" (dropExtension out)

  (not . hasExtension) ?> \out -> need [out <.> "lp"]

processTjDepend :: FilePath -> Action ()
processTjDepend out = do
  Stdout mf <- cmd "tjdepend" (out -<.> "mod")
  let deps = fromMaybe [] $ lookup (takeFileName out) $ parseMakefile mf
  need deps
