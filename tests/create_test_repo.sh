#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# ==============================================================================
# Helper Script: Create Test Git Repository
# Target: Must be an empty directory (or non-existent, in which case it will be created)
# ==============================================================================

if [ "$#" -ne 1 ]; then
    echo "Error: Target directory required."
    echo "Usage: $0 <target_empty_directory>"
    exit 1
fi

TARGET_DIR="$1"

# Check if target directory exists and is non-empty
if [ -d "$TARGET_DIR" ]; then
    # Count files including hidden ones (excluding . and ..)
    FILE_COUNT=$(find "$TARGET_DIR" -maxdepth 1 -mindepth 1 | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "Error: Target directory '$TARGET_DIR' exists and is not empty ($FILE_COUNT item(s) found)."
        exit 1
    fi
else
    mkdir -p "$TARGET_DIR"
fi

# Convert to absolute path
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo "Initializing test Git repository in: $TARGET_DIR"

# Change into target directory
cd "$TARGET_DIR"

# 1. Initialize repository with default branch 'main'
git init -b main

# Configure local user for reproducible test commits
git config user.name "Test Bot"
git config user.email "testbot@agengit.local"

# 2. Add base files & initial commit on 'main'
cat << 'EOF' > README.md
# Agengit Testing Sandbox Repository

This repository is an isolated test environment with predefined branches, tags, and commits.
EOF

cat << 'EOF' > config.json
{
  "name": "agengit-test-config",
  "version": "1.0.0"
}
EOF

mkdir -p src docs
echo "// Main entry point" > src/main.txt
echo "# Documentation" > docs/info.md

cat << 'EOF' > .gitignore
*.log
build/
tmp/
EOF

git add .
git commit -m "Initial commit on main"

# 3. Create tags
git tag v1.0.0
git tag -a v1.0.1-release -m "Release v1.0.1"

# 4. Create temporary bare remote to populate origin tracking branches
TEMP_REMOTE=$(mktemp -d)
git init --bare "$TEMP_REMOTE" > /dev/null
git remote add origin "$TEMP_REMOTE"
git push -u origin main > /dev/null 2>&1

# 5. Create 'dev/feature-1' branch (clean & pushed to origin)
git checkout -b dev/feature-1 > /dev/null 2>&1
echo "// Feature 1 logic added" >> src/main.txt
git add src/main.txt
git commit -m "Implement feature 1" > /dev/null
git push -u origin dev/feature-1 > /dev/null 2>&1

# 6. Create 'dev-bugfix-2' branch (clean dev- prefix)
git checkout main > /dev/null 2>&1
git checkout -b dev-bugfix-2 > /dev/null 2>&1
echo "// Bugfix 2 patch" >> src/main.txt
git add src/main.txt
git commit -m "Apply bugfix 2" > /dev/null
git push -u origin dev-bugfix-2 > /dev/null 2>&1

# 7. Create 'dev/merged-feature' branch (merged into main)
git checkout main > /dev/null 2>&1
git checkout -b dev/merged-feature > /dev/null 2>&1
echo "// Merged feature documentation" >> README.md
git add README.md
git commit -m "Add merged feature docs" > /dev/null
git checkout main > /dev/null 2>&1
git merge dev/merged-feature --no-ff -m "Merge branch 'dev/merged-feature' into main" > /dev/null 2>&1
git push origin main > /dev/null 2>&1

# 8. Create 'dev/unmerged-feature' branch (unmerged work)
git checkout main > /dev/null 2>&1
git checkout -b dev/unmerged-feature > /dev/null 2>&1
echo "Unmerged experimental feature work" > src/experimental.txt
git add src/experimental.txt
git commit -m "Work on unmerged feature" > /dev/null

# 9. Create 'dev/ahead' branch (ahead of origin tracking ref)
git checkout main > /dev/null 2>&1
git checkout -b dev/ahead > /dev/null 2>&1
git push -u origin dev/ahead > /dev/null 2>&1
echo "Ahead commit 1" >> README.md
git add README.md
git commit -m "Commit 1 ahead of origin" > /dev/null
echo "Ahead commit 2" >> README.md
git add README.md
git commit -m "Commit 2 ahead of origin" > /dev/null

# 10. Create 'feature/invalid-name' branch (non-dev prefix to test policy blocks)
git checkout main > /dev/null 2>&1
git checkout -b feature/invalid-name > /dev/null 2>&1
echo "Forbidden branch content" > forbidden.txt
git add forbidden.txt
git commit -m "Work on non-dev branch" > /dev/null

# 11. Final cleanup: return to main and set origin URL to dummy remote
git checkout main > /dev/null 2>&1
rm -rf "$TEMP_REMOTE"
git remote set-url origin "https://github.com/agengit-testing/agengit-testing-sandbox.git"

echo "Successfully created test Git repository at: $TARGET_DIR"
