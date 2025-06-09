import requests
import os
import re
import semantic_version


def get_changes_since_last_release(owner, repo, branch, token, apps):
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    app_changes = {}

    for app in apps:
        try:
            commits_since_release = []
            relevant_commits = []
            relevant_commits_since_release = []

            # 1. Get the latest release tag for the current app
            tags_url = f"https://api.github.com/repos/{owner}/{repo}/tags"
            tags_response = requests.get(tags_url, headers=headers)
            tags_response.raise_for_status()
            tags_data = tags_response.json()

            latest_release_tag = None
            for tag in tags_data:
                print(app + " " + tag["name"])
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

                while commits_url:
                    commits_response = requests.get(commits_url, headers=headers)
                    commits_response.raise_for_status()
                    commits_data = commits_response.json()

                    for commit in commits_data:
                        message = commit["commit"]["message"]
                        lower_message = message.lower()
                        if "breaking change" in lower_message or \
                            lower_message.startswith(("feat:", "fix:")) or \
                            (lower_message.startswith("chore:") and "breaking change" in lower_message):
                            relevant_commits.append(commit)

                    commits_url = commits_response.links.get("next", {}).get("url")
            else:
                relevant_commits = [] 

            # 4. Filter commits to those after the latest release (if a release exists)
            if latest_release_sha:
                relevant_commits_since_release = [
                    commit for commit in relevant_commits if commit["sha"] > latest_release_sha
                ]
                #filter to commits where the file relates to this app
                for commit in relevant_commits_since_release:
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
                major_change = False
                minor_change = False
                patch_change = False
                for commit in commits_since_release:
                    lower_message = commit["commit"]["message"].lower()
                    if "breaking change" in lower_message:
                        #check for a breaking/major change
                        major_change = True
                    elif lower_message.startswith("feat:"):
                        #check for a minor change
                        minor_change = True
                    elif lower_message.startswith("fix:"):
                        #check for a patch change
                        patch_change = True    
                if major_change:
                    new_version = current_version.next_major()
                elif minor_change:
                    new_version = current_version.next_minor()
                elif patch_change:
                    new_version = current_version.next_patch()   
                else:
                    new_version = None

                app_changes[app] = {
                "changes": [commit["commit"]["message"] for commit in commits_since_release],
                "new_version": str(new_version) if commits_since_release else None,
                "commits_since_release": commits_since_release 
                }
            else:
                commits_since_release =[]
                new_version = None
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
    release_name = f"{app}/v{new_version}"
    release_body = f"Release notes for {app}/v{new_version}:\n\n"
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
    dry_run = False

    root_path = os.getcwd()
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
                if not dry_run:
                    create_release(owner, repo, app, app_data["new_version"], app_data["commits_since_release"], token)
        else:
            print(f"No changes for {app} since last release.")
