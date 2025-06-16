#!/bin/bash

# --- Configuration ---
# Replace with your desired version number
VERSION="v1.0.0"
# Replace with your desired release title
RELEASE_TITLE="My First Release ($VERSION)"
# Path to your release notes file (optional)
NOTES_FILE="RELEASE_NOTES.md"
# Your GitHub repository (e.g., owner/repo_name)
# If you run this script inside your cloned repo, gh will usually infer this.
# Otherwise, you can explicitly set it:
# REPO="your_github_username/your_repo_name"

# --- Script Logic ---

echo "--- Starting GitHub Release Automation Script ---"

# 1. Check if gh CLI is installed
if ! command -v gh &> /dev/null
then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to proceed."
    echo "Instructions: https://cli.github.com/"
    exit 1
fi

# 2. Check gh authentication status (optional but recommended)
echo "Checking gh authentication status..."
if ! gh auth status &> /dev/null; then
    echo "gh CLI not authenticated. Please run 'gh auth login' to authenticate."
    exit 1
else
    echo "gh CLI authenticated."
fi

# 3. Ensure you are in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a Git repository. Please run this script from your project's root."
    exit 1
fi

# 4. Create the release with gh release create
echo "Attempting to create GitHub release for tag: $VERSION..."

# Common options for gh release create:
#
# <tag>: The tag name for the release (e.g., v1.0.0). If the tag doesn't exist, gh will create it from the current branch's HEAD.
# --title <string>: The title of the release.
# --notes <string>: Release notes as a string.
# --notes-file <file>: Read release notes from a file. Use "-" to read from stdin.
# --generate-notes: Automatically generate notes based on commits since the last release.
# --draft: Save the release as a draft (not published immediately).
# --prerelease: Mark the release as a pre-release.
# --target <branch/commit>: Specify the branch or commit SHA to create the tag from (if the tag doesn't exist).
# --discussion-category <string>: Start a discussion in a specific category.
# [<filename> | <pattern>...]: Add assets to the release (e.g., ./build/*.zip)

if [ -f "$NOTES_FILE" ]; then
    echo "Using notes from $NOTES_FILE"
    gh release create "$VERSION" \
        --title "$RELEASE_TITLE" \
        --notes-file "$NOTES_FILE" \
        --prerelease # Example: Mark as prerelease
        # --latest=false # Example: Don't mark as latest (if you have multiple releases)
else
    echo "No $NOTES_FILE found, generating notes automatically."
    gh release create "$VERSION" \
        --title "$RELEASE_TITLE" \
        --generate-notes \
        --prerelease # Example: Mark as prerelease
fi

# Check the exit status of the gh command
if [ $? -ne 0 ]; then
    echo "Error: Failed to create GitHub release."
    exit 1
fi

echo "GitHub release '$RELEASE_TITLE' (tag: $VERSION) created successfully!"
echo "Don't forget to push your local tags to the remote if gh didn't do it automatically (it usually does for new tags):"
echo "git push origin $VERSION" # To push just this tag
echo "or: git push --tags"      # To push all local tags

echo "--- Script finished ---"
