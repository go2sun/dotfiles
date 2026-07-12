#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
brew update && brew upgrade && mas upgrade && brew cleanup --prune=all && rm -rf $(brew --cache)
say "system updated"
