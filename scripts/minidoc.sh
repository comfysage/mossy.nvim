#!/usr/bin/env bash
rm -r doc
nvim --headless "$@" -l minidoc.lua
