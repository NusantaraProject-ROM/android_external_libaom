#!/bin/bash -e
#
# Copyright (c) 2012 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This tool is used to update libaom source code to a revision of the upstream
# repository.

# Usage:
#
# $ ./update_libaom.sh [branch | revision | file or url containing a revision]
# When specifying a branch it may be necessary to prefix with origin/

# Tools required for running this tool:
#
# 1. Linux / Mac
# 2. git

export LC_ALL=C

# Location for the remote git repository.
GIT_REPO="https://aomedia.googlesource.com/aom"

# Update to TOT by default.
GIT_BRANCH="origin/master"

# Relative path of target checkout.
LIBAOM_SRC_DIR="libaom"

BASE_DIR=`pwd`

if [ -n "$1" ]; then
  GIT_BRANCH="$1"
  if [ -f "$1"  ]; then
    GIT_BRANCH=$(<"$1")
  elif [[ $1 = http* ]]; then
    GIT_BRANCH=`curl $1`
  fi
fi

prev_hash="$(egrep "^Commit: [[:alnum:]]" README.android | awk '{ print $2 }')"
echo "prev_hash:$prev_hash"

rm -rf $LIBAOM_SRC_DIR
# be robust in the face of errors (meaning don't overwrite the wrong place)
mkdir $LIBAOM_SRC_DIR || exit 1
cd $LIBAOM_SRC_DIR || exit 1

# Start a local git repo.
git clone $GIT_REPO .

# Switch the content to the desired revision.
git checkout -b tot $GIT_BRANCH

add="$(git diff-index --diff-filter=A $prev_hash | \
tr -s [:blank:] ' ' | cut -f6 -d\ )"
delete="$(git diff-index --diff-filter=D $prev_hash | \
tr -s [:blank:] ' ' | cut -f6 -d\ )"

# Get the current commit hash.
hash=$(git log -1 --format="%H")

# README reminder.
(
    # keep meta info / header
    sed -n '0,/^====/p' < ../README.android

    # sed kept it in there
    #echo "========"

    echo "Date: $(date +"%A %B %d %Y")"
    echo "Branch: $GIT_BRANCH"
    echo "Commit: $hash"
    echo ""
) > ../update.$$-README.android
cat ../update.$$-README.android
mv ../update.$$-README.android ../README.android

# Commit message header.
COMMIT_MSG=../commit-message-`date +"%Y%m%d.%H%M%S"`
(
    echo "libaom: Pull from upstream"
    echo ""

    # Output the current commit hash.
    echo "Prev HEAD: $prev_hash"
    echo "New  HEAD: $hash"
    echo ""

    # Output log for upstream from current hash.
    if [ -n "$prev_hash" ]; then
      echo "git log from upstream:"
      pretty_git_log="$(git log \
                    --no-merges \
                    --topo-order \
                    --pretty="%h %s" \
                    --max-count=20 \
                    $prev_hash..$hash)"
      if [ -z "$pretty_git_log" ]; then
        echo "No log found. Checking for reverts."
        pretty_git_log="$(git log \
                      --no-merges \
                      --topo-order \
                      --pretty="%h %s" \
                      --max-count=20 \
                      $hash..$prev_hash)"
      fi
      echo "$pretty_git_log"
      # If it makes it to 20 then it's probably skipping even more.
      if [ `echo "$pretty_git_log" | wc -l` -eq 20 ]; then
        echo "<...>"
      fi
    else
      # no previous hash
      echo "git log from upstream:"
      pretty_git_log="$(git log \
                    --no-merges \
                    --topo-order \
                    --pretty="%h %s" \
                    --max-count=20)"
      if [ -z "$pretty_git_log" ]; then
        echo "No log found. Checking for reverts."
      fi
      echo "$pretty_git_log"
      # If it makes it to 20 then it's probably skipping even more.
      if [ `echo "$pretty_git_log" | wc -l` -eq 20 ]; then
        echo "<...>"
      fi
    fi
) > ${COMMIT_MSG}

# Tell user about it
echo "Commit message: (stored in ./${COMMIT_MSG})"
echo "==============="
cat ${COMMIT_MSG}
echo ""
echo "==============="

# Git is useless now, remove the local git repo.
rm -rf .git .gitignore .gitattributes

# Add and remove files.
echo "$add" | xargs -I {} git add {}
echo "$delete" | xargs -I {} git rm --ignore-unmatch {}

# Find empty directories and remove them.
find . -type d -empty -exec git rm {} \;

chmod 755 build/cmake/*.sh build/cmake/*.pl

# not even sure why we're doing a chdir here as the last thing in the script
# it isn't going to make any difference semantically.
cd $BASE_DIR || exit 1
