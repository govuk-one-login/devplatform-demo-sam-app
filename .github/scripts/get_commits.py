import os
import subprocess

def get_commits_since_last_release(repository, branch='main'):
    """Retrieves commit messages since the last release on a specified branch."""
    try:
        # 1. Get the latest release tag
        latest_release_tag = subprocess.check_output(
            ["gh", "release", "list", "--repo", repository, "--limit", "1", "--json", "tagName", "--jq", ".[0].tagName"],
            text=True,
            stderr=subprocess.STDOUT  # Capture errors to stdout
        ).strip()

        # 2. Get the commit SHA of the latest release tag
        latest_release_sha = subprocess.check_output(
            ["git", "rev-list", "-n", "1", latest_release_tag],
            text=True,
            stderr=subprocess.STDOUT
        ).strip()

        # 3. Get commits since the latest release on the specified branch
        commits = subprocess.check_output(
            ["git", "log", "--pretty=format:%s", f"{latest_release_sha}..{branch}"],
            text=True,
            stderr=subprocess.STDOUT
        ).splitlines()

        return commits

    except subprocess.CalledProcessError as e:
        if "gh: release not found" in e.output or "fatal: ambiguous argument" in e.output:
            # Handle the case where there are no releases yet
            commits = subprocess.check_output(
                ["git", "log", "--pretty=format:%s", branch],
                text=True,
                stderr=subprocess.STDOUT
            ).splitlines()
            return commits
        else:
            print(f"Error getting commits: {e.output}")
            return []

if __name__ == "__main__":
    repository = os.environ.get("GITHUB_REPOSITORY")  # Get repository from environment
    branch = "cg-test"  # Replace with your test branch name
    commits = get_commits_since_last_release(repository, branch)

    if commits:
        print("Commits since last release:")
        for commit in commits:
            print(commit)
    else:
        print("No commits found since the last release.")
