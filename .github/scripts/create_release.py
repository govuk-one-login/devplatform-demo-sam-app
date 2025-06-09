import requests
import os
import re
import semantic_version

DRY_RUN = True

def get_changes_since_last_release(owner, repo, branch, token, apps):
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    app_changes = {}

    for app in apps:
        try:
            # 1. Get the latest release tag for the current app
            tags_url = f"https://api.github.com/repos/{owner}/{repo}/tags"
            tags_response = requests.get(tags_url, headers=headers)
            tags_response.raise_for_status()
            tags_data = tags_response.json()

            latest_release_tag = None
            for tag in tags_data:
                if tag["name"].startswith(f"{app}/v"):
                    if latest_release_tag is None or version.parse(tag["name"]) > version.parse(latest_release_tag):
                        latest_release_tag = tag["name"]

            if latest_release_tag is None:
                print(f"No releases found for {app}.")
                latest_release_sha = None
                current_version = semantic_version.Version("0.0.0")
            else:
                # 2. Get commit SHA of the latest release tag
                tag_sha_url = f"https://api.github.com/repos/{owner}/{repo}/git/ref/tags/{latest_release_tag}"
                tag_sha_response = requests.get(tag_sha_url, headers=headers)
                tag_sha_response.raise_for_status()
                latest_release_sha = tag_sha_response.json()["object"]["sha"]
                current_version_str = latest_release_tag.split("/")[-1].lstrip("v")
                current_version = semantic_version.Version(current_version_str)

            # 3. Get commits on the branch and filter
            if latest_release_tag is not None:
                commits_url = f"https://api.github.com/repos/{owner}/{repo}/commits?sha={branch}"
                relevant_commits = []
                breaking_change = False

                while commits_url:
                    commits_response = requests.get(commits_url, headers=headers)
                    commits_response.raise_for_status()
                    commits_data = commits_response.json()

                    for commit in commits_data:
                        message = commit["commit"]["message"]
                        if "BREAKING CHANGE" in message:
                            breaking_change = True
                            relevant_commits.append(commit)
                        elif re.match(r"^(feat|fix|chore)(\(.*\))?:.*", message, re.IGNORECASE):
                            relevant_commits.append(commit)

                    commits_url = commits_response.links.get("next", {}).get("url")
            else:
                breaking_change = False
                relevant_commits = []

            # 4. Filter commits to those after the latest release (if a release exists)
            if latest_release_sha:
                relevant_commits_since_release = [
                    commit for commit in relevant_commits if commit["sha"] > latest_release_sha
                ]
                #filter to commits where the file relates to this app
                for commit in relevant_commits:
                    commit_sha = commit["sha"]
                    commit_url = f"https://api.github.com/repos/{owner}/{repo}/commits/{commit_sha}"
                    commit_response = requests.get(commit_url, headers=headers)
                    commit_response.raise_for_status()
                    commit_details = commit_response.json()
                    files_changed = commit_details["files"]
                    message = commit["commit"]["message"]
                    # Check if any changed file is within the app's directory
                    app_relevant = False
                    for file in files_changed:
                        file_path = os.path.relpath(file['filename'], root_path) # Make path relative to root
                        if file_path.startswith(app + "/"):  # Check if file is within the app's directory
                            app_relevant = True
                            break 

                    if app_relevant:    
                        commits_since_release.append(commit)

                # 5. Determine new version
                if breaking_change:
                    new_version = current_version.next_major()
                elif any(re.match(r"^feat\(.*\):.*", commit["commit"]["message"], re.IGNORECASE) for commit in relevant_commits):
                    new_version = current_version.next_minor()
                elif any(re.match(r"^fix\(.*\):.*", commit["commit"]["message"], re.IGNORECASE) for commit in relevant_commits):
                    new_version = current_version.next_patch()
                else:
                    new_version = current_version

                app_changes[app] = {
                "changes": [commit["commit"]["message"] for commit in commits_since_release],
                "new_version": str(new_version) if commits_since_release else None,
                "commits_since_release": commits_since_release # Add this line
            }
            else:
                #commits_since_release = relevant_commits
                commits_since_release =[]
                new_version = current_version
                app_changes[app] = {"changes": [], "new_version": None, "commits_since_release": []}   

        except requests.exceptions.RequestException as e:
            print(f"Error during API request for {app}: {e}")
            app_changes[app] = {"changes": [], "new_version": None, "commits_since_release": []}
        except KeyError as e:
            print(f"Error parsing API response for {app}: {e}")
            app_changes[app] = {"changes": [], "new_version": None, "commits_since_release": []}
        except ValueError as e:
            print(f"Error parsing version string for {app}: {e}")
            app_changes[app] = {"changes": [], "new_version": None, "commits_since_release": []}

    return app_changes



def create_release(owner, repo, app, new_version, commits_since_release, token):
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    tag_name = f"{app}/v{new_version}"
    release_name = f"{app} v{new_version}"
    release_body = f"Release notes for {app} v{new_version}:\n\n"
    for commit in commits_since_release:
        release_body += f"- {commit['commit']['message']}\n"


    release_url = f"https://api.github.com/repos/{owner}/{repo}/releases"
    release_data = {
        "tag_name": tag_name,
        "name": release_name,
        "body": release_body,
        "draft": False,  # Set to True for a draft release
        "prerelease": False, # Set to True for a pre-release
        "target_commitish": branch # Specify the target branch
    }

    try:
        release_response = requests.post(release_url, headers=headers, json=release_data)
        release_response.raise_for_status()
        print(f"Release created for {app}: {tag_name}")
    except requests.exceptions.RequestException as e:
        print(f"Error creating release for {app}: {e}")



if __name__ == "__main__":
    owner = os.environ["GITHUB_REPOSITORY_OWNER"]
    repo = os.environ["GITHUB_REPOSITORY"].split("/")[-1]
    branch = "PSREDEV-2337"  # Replace with your branch name
    token = os.environ["GITHUB_TOKEN"]

    root_path = os.getcwd()
    print(root_path)
    os.chdir(root_path)  # Change to the root directory
    apps = [
        d for d in os.listdir(".")  # List current directory (which is now the root)
        if os.path.isdir(d) and not d.startswith(".")
    ]
    if not apps:
        print("No app directories found.")
        exit(1)  # Or handle appropriately

    changes = get_changes_since_last_release(owner, repo, branch, token, apps)

    for app, app_data in changes.items():
        print("")
        if app_data["changes"]:
            print(f"New version for {app}: {app_data['new_version']}")
            print(f"Changes for {app} since last release:")  # Corrected output message
            for commit in app_data["changes"]:
                print(f"  - {commit}")
            if app_data["new_version"]: # Only create a release if there's a new version
                if not DRY_RUN:
                    create_release(owner, repo, app, app_data["new_version"], commits_since_release, token)
        else:
            print(f"No changes for {app} since last release.")
