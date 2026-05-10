#!/usr/bin/env bash
# One-shot: finish the local commit and push CineBook to GitHub over SSH.
# Assumes you've already created the EMPTY repo at https://github.com/new
# with name "cinebook", Public, and NO README/.gitignore/license.

set -e
cd "$(dirname "$0")"

# 1) Clear any stale lock from the sandbox session
rm -f .git/index.lock

# 2) Untrack Xcode user-specific files (idempotent) and add the new .gitignore
git rm -r --cached CineBook.xcodeproj/xcuserdata 2>/dev/null || true
git add .gitignore

# 3) Commit only if there is something to commit
if ! git diff --cached --quiet; then
  git commit -m "Add Xcode .gitignore and untrack user-specific files"
fi

# 4) Wire up the remote (skip if already set) and push
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin git@github.com:MKUTS05/cinebook.git
fi

git branch -M main
git push -u origin main

echo
echo "Done. View your repo at: https://github.com/MKUTS05/cinebook"
