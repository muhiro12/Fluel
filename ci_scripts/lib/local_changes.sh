#!/usr/bin/env bash

ci_collect_changed_files() {
  {
    git diff --name-only --cached
    git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
}
