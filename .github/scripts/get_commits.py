import requests
import os

def get_commits_since_release_api(owner, repo, branch, token):
    """Retrieves commit messages since the last release using the GitHub API."""

    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    try:
        # 1. Get the latest release tag
        release_url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        release_response = requests.get(release_url, headers=headers)
        release_response.raise_for_status()
        latest_release_tag = release_response.json()["tag_name"]

        # 2. Get the commit SHA of the tag
        tag_sha_url = f"https://api.github.com/repos/{owner}/{repo}/git/ref/tags/{latest_release_tag}"
        tag_sha_response = requests.get(tag_sha_url, headers=headers)
        tag_sha_response.raise_for_status()
        latest_release_sha = tag_sha_response.json()["object"]["sha"]

        # 3. Get commits on the branch (initialize commits_url)
        commits_url = f"https://api.github.com/repos/{owner}/{repo}/commits?sha={branch}"  # Initialize here
        commits_data_all = []
        while commits_url:
            commits_response = requests.get(commits_url, headers=headers)
            commits_response.raise_for_status()
            commits_data = commits_response.json()
            commits_data_all.extend(commits_data)  # Extend with full commit objects
            commits_url = commits_response.links.get("next", {}).get("url")


        # 4. Filter commits to those after the latest release (using SHA)
        commits_since_release = [
            commit for commit in commits_data_all if commit["sha"] > latest_release_sha
        ]

        # 5. Extract commit messages after filtering
        commit_messages = [commit["commit"]["message"] for commit in commits_since_release]
        return commit_messages

    except requests.exceptions.RequestException as e:
        if "404" in str(e):  # Check if the error is a 404 (Not Found)
            print("No releases found. Getting all commits from the branch.")
            commits_url = f"https://api.github.com/repos/{owner}/{repo}/commits?sha={branch}"
            commits_data_all = []
            while commits_url:
                commits_response = requests.get(commits_url, headers=headers)
                commits_response.raise_for_status()
                commits_data = commits_response.json()
                commits_data_all.extend(commits_data)
                commits_url = commits_response.links.get("next", {}).get("url")

            commit_messages = [commit["commit"]["message"] for commit in commits_data_all]
            return commit_messages  # Return all commits if no release exists
        else:  # Handle other request errors
            print(f"Error during API request: {e}")
            return []
    except KeyError as e:
        print(f"Error parsing API response: {e}")
        return []

if __name__ == "__main__":
    owner = os.environ["GITHUB_REPOSITORY_OWNER"]
    repo = os.environ["GITHUB_REPOSITORY"].split("/")[-1]
    branch = "cg-test"  # Replace with your branch name
    token = os.environ["RELEASE_CREATION_POC"]  # Or your PAT

    commits = get_commits_since_release_api(owner, repo, branch, token)

    if commits:
        print("Commits since last release:")
        for commit in commits:
            print(commit)
    else:
        print("No commits found since the last release or error during API calls.")
