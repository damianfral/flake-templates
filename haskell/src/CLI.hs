{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE NoImplicitPrelude #-}

module CLI where

import Data.GenValidity (GenValid, Validity)
import Data.GenValidity.Text ()
import Data.Text
import Data.Text.IO
import Data.Version (showVersion)
import Options.Applicative.Types
import Options.Generic
import Paths_hello (version)
import Relude hiding (putStrLn)

--------------------------------------------------------------------------------

data Enthusiasm
  = None
  | Normal
  | High
  deriving (Show, Read, Typeable, Generic, Eq, Enum)

instance ParseField Enthusiasm where
  metavar _ = "ENTHUSIASM"
  readField = do
    str <- readerAsk
    case toLower $ pack str of
      "0" -> pure None
      "1" -> pure Normal
      "2" -> pure High
      _ -> fail "could not parse Enthusiasm"

instance ParseFields Enthusiasm

instance ParseRecord Enthusiasm

instance Validity Enthusiasm

instance GenValid Enthusiasm

--------------------------------------------------------------------------------

data Options w = Options
  { name :: w ::: Text <?> "Your name",
    enthusiasm :: w ::: Enthusiasm <?> "Level of enthusiasm [0,1,2]"
  }
  deriving (Generic)

instance ParseRecord (Options Wrapped)

deriving instance Show (Options Unwrapped)

deriving instance Eq (Options Unwrapped)

instance Validity (Options Unwrapped)

instance GenValid (Options Unwrapped)

--------------------------------------------------------------------------------

runCLIOptions :: Options Unwrapped -> IO ()
runCLIOptions Options {..} = putStrLn message >> exitSuccess
  where
    message = case enthusiasm of
      None -> "Hi, " <> name <> "!"
      Normal -> "Hey " <> name <> "!! It's great to have you here!"
      High -> "Hi, " <> name <> "."

runCLI :: IO ()
runCLI = do
  options <-
    unwrapRecord $
      Relude.unwords
        [ "hello",
          "v" <> pack (showVersion version),
          "- a simple haskell application"
        ]
  runCLIOptions options
