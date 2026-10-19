#!/usr/bin/env bash

toInstall="ruby rubygems ruby-irb ruby-stdlib"

sudo pacman --needed -S $toInstall

gem install solargraph
