#!/bin/bash

# --- Configuration ---
DEFAULT_BRANCH="PSREDEV-2337" # Your default branch (e.g., main or master)
APPS_DIR_PARENT="./" # Parent directory containing your app folders (e.g., ./ or ./packages)
# List of applications to manage. If not specified, script will try to detect subdirectories.
# If you have specific apps that might not be direct subdirectories (e.g., deeply nested),
# or you only want to manage a subset, list them explicitly here:
# APPS=("app1" "app2" "app3")
# If APPS is empty, the script will try to find subdirectories in APPS_DIR_PARENT
APPS=()

# --- Functions ---

# Function to get the last release tag for a specific app
# Searches for tags matching the pattern "app_name/*"
get_last_app_release_tag() {
    local app_name="$1"
    # Find the latest tag that starts with the app's name, ordered by version (desc)
    # Assumes semantic versioning in tags like 'app1/v1.2.3'
    git tag --list "$app_name/v*" | sort -V | tail -n 1
}

# Function to get commits for a specific app since its last release
get_app_commits_since_last_release() {
    local app_name="$1"
    local last_tag="$2"
    local target_branch="$3"

    if [ -z "$last_tag" ]; then
        # If no previous tag, get all commits in the app's directory on the target branch
        git log --pretty=format:"- %s (%h)" "$target_branch" -- "$app_name"
    else
        # Get commits between the last tag and the target branch HEAD, restricted to the app's directory
        git log --pretty=format:"- %s (%h)" "$last_tag".."$target_branch" -- "$app_name"
    fi
}

# Function to generate conventional release notes for an app
generate_app_release_notes() {
    local app_name="$1"
    local last_tag="$2"
    local target_branch="$3"

    # Use 'git log' with '--format=%B' to get full commit messages
    # Pipe through a simple awk script to format for release notes
    # This is a very basic example; for full Conventional Commits, you'd use a tool like 'conventional-changelog'
    if [ -z "$last_tag" ]; then
        NOTES=$(git log --format="%B" "$target_branch" -- "$app_name" | awk '/^(feat|fix|chore|docs|refactor|perf|test|build|ci):/ { print "- " $0 }')
    else
        NOTES=$(git log --format="%B" "$last_tag".."$target_branch" -- "$app_name" | awk '/^(feat|fix|chore|docs|refactor|perf|test|build|ci):/ { print "- " $0 }')
    fi

    if [ -z "$NOTES" ]; then
        echo "No significant changes found (feat, fix, etc.)."
        echo "No detailed notes generated. Creating generic notes."
        echo "## Changes for $app_name"
        echo "See commit history for details."
    else
        echo "## Changes for $app_name"
        echo ""
        echo "$NOTES"
    fi
}


# --- Script Logic ---

echo "--- Monorepo Release Automation Script ---"

# 1. Check if gh CLI is installed
if ! command -v gh &> /dev/null
then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to proceed."
    echo "Instructions: https://cli.github.com/"
    exit 1
fi

# 2. Check gh authentication status
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

# 4. Ensure we are on the default branch (or the branch for releases)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
    echo "Warning: Not on the '$DEFAULT_BRANCH' branch. Current branch is '$CURRENT_BRANCH'."
    echo "Releases should ideally be cut from '$DEFAULT_BRANCH'."
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo # Newline
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

# 5. Get list of apps if not explicitly defined
if [ ${#APPS[@]} -eq 0 ]; then
    echo "Detecting applications in '$APPS_DIR_PARENT'..."
    for d in "$APPS_DIR_PARENT"*/; do
        if [ -d "$d" ]; then
            app_name=$(basename "$d")
            # Basic check to ensure it's an app, not just any directory
            # e.g., check for package.json, src dir, or specific marker file
            echo $app_name
            #if [[ ! "$app_name" == .* ]]; then
                 APPS+=("$app_name")
                 echo "  - Found app: $app_name"
            #fi
        fi
    done
    if [ ${#APPS[@]} -eq 0 ]; then
        echo "Error: No applications detected. Please define APPS array or ensure directories have a package.json/src."
        exit 1
    fi
fi

echo "Detected applications: ${APPS[@]}"

# 6. Iterate through each app to check for changes and create releases
for APP_NAME in "${APPS[@]}"; do
    echo ""
    echo "--- Processing app: $APP_NAME ---"

    LAST_APP_TAG=$(get_last_app_release_tag "$APP_NAME")
    if ! [ -z "$LAST_APP_TAG" ]; then
        echo "Last release tag for $APP_NAME: ${LAST_APP_TAG:-None}"
    else
         echo "No last release tag found for $APP_NAME - skipping"
    fi    


    # Determine the reference point for changes
    if ! [ -z "$LAST_APP_TAG" ]; then
        CHANGES_FROM_REF="$LAST_APP_TAG"
        echo "Checking for changes since $LAST_APP_TAG."
    fi

    # Check if there are changes in the app's directory since the last release tag (or first commit)
    # Using 'git diff-tree --name-only -r' is reliable for changes in a path
    # 'HEAD' refers to the current commit of the branch we are on
    if ! [ -z "$LAST_APP_TAG" ]; then
        if git diff-tree --name-only -r "$CHANGES_FROM_REF".."$DEFAULT_BRANCH" -- "$APP_NAME" | grep -q .; then
            echo "Changes detected in '$APP_NAME'."

            # --- Automated Version Bumping (Example using Conventional Commits) ---
            # This is a critical and complex part of monorepo management.
            # For simplicity, we'll manually increment based on a prompt or use a placeholder.
            # In a real CI/CD, you'd use a tool like 'lerna version' or 'semantic-release'
            # with monorepo support to determine the next version based on commit types.

            # Placeholder for next version calculation
            # In a real scenario, you'd parse commit messages or increment manually.
            read -p "Enter next version for $APP_NAME (e.g., 1.0.0, 1.0.0-beta): " NEXT_VERSION
            if [ -z "$NEXT_VERSION" ]; then
                echo "Version not provided for $APP_NAME. Skipping release for this app."
                continue
            fi

            NEW_TAG_NAME="${APP_NAME}/v${NEXT_VERSION}"
            RELEASE_TITLE="${APP_NAME} v${NEXT_VERSION}"

            echo "Proposed new tag: $NEW_TAG_NAME"
            echo "Proposed release title: $RELEASE_TITLE"

            # Generate Release Notes
            RELEASE_NOTES=$(generate_app_release_notes "$APP_NAME" "$LAST_APP_TAG" "$DEFAULT_BRANCH")
            echo -e "\n--- Generated Release Notes for $APP_NAME ---\n$RELEASE_NOTES\n--------------------------------------------"

            # --- Confirm Release ---
            read -p "Do you want to create a release for $APP_NAME with tag $NEW_TAG_NAME? (y/N): " -n 1 -r
            echo # Newline
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Skipping release for $APP_NAME."
                continue
            fi

            # 7. Create the Git tag locally
            # This tag needs to point to the commit on DEFAULT_BRANCH
            echo "Creating local Git tag $NEW_TAG_NAME at $DEFAULT_BRANCH HEAD..."
            git tag "$NEW_TAG_NAME" "$DEFAULT_BRANCH"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to create local Git tag $NEW_TAG_NAME. Skipping this app."
                continue
            fi

            # 8. Create the GitHub Release
            echo "Creating GitHub Release for $APP_NAME ($NEW_TAG_NAME)..."
            # We use --notes-file - to pass the generated notes via stdin
            echo "$RELEASE_NOTES" | gh release create "$NEW_TAG_NAME" \
                --title "$RELEASE_TITLE" \
                --notes-file - \
                --target "$DEFAULT_BRANCH" \
                --latest=true # Mark as latest for this app's specific tags

            if [ $? -ne 0 ]; then
                echo "Error: Failed to create GitHub release for $APP_NAME."
                echo "Attempting to delete local tag $NEW_TAG_NAME..."
                git tag -d "$NEW_TAG_NAME"
                continue # Continue to next app
            fi

            echo "Successfully created release for $APP_NAME ($NEW_TAG_NAME)."
            echo "Make sure to push your local tags to remote later if you haven't already:"
            echo "  git push origin $NEW_TAG_NAME"

        else
            echo "No significant changes detected in '$APP_NAME' since $LAST_APP_TAG. Skipping release for this app."
        fi
    fi
done

echo ""
echo "--- Monorepo Release Script Finished ---"
echo "Remember to run 'git push --tags' to push all new tags to GitHub."