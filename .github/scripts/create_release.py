import requests
import os

def create_github_release(token, repository, tag_name, release_name, target_commitish, body, draft=False, prerelease=False):
    """Creates a GitHub release, including tag creation, using the API."""

    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    # 1. Create the tag
    tag_data = {
        "tag": tag_name,
        "message": "Creating tag for release",  # Optional tag message
        "object": target_commitish, # The SHA of the commit to tag
        "type": "commit", # The type of object to tag
        "tagger": { # Details of the tagger
            "name": "GitHub Actions", # Name of the tagger
            "email": "actions@github.com", # Email of the tagger
            "date": "2024-07-26T12:00:00Z" # Date of the tag in ISO 8601 format
        }
    }

    tag_url = f'https://api.github.com/repos/{repository}/git/tags'
    tag_response = requests.post(tag_url, headers=headers, json=tag_data)

    if tag_response.status_code != 201:
        print(f"Error creating tag: {tag_response.status_code}")
        print(tag_response.text)
        return

    # 2. Create the release (after the tag is created)
    release_data = {
        'tag_name': tag_name,
        'name': release_name,
        'target_commitish': target_commitish,
        'body': body,
        'draft': draft,
        'prerelease': prerelease
    }

    release_url = f'https://api.github.com/repos/{repository}/releases'
    release_response = requests.post(release_url, headers=headers, json=release_data)

    if release_response.status_code == 201:
        print("Release created successfully!")
        print(release_response.json())
    else:
        print(f"Error creating release: {release_response.status_code}")
        print(release_response.text)


if __name__ == "__main__":
    token = os.environ['GITHUB_TOKEN']
    repository = os.environ['GITHUB_REPOSITORY']  # Get repo from environment
    print(repository)
    tag_name = 'v1.0.6'
    release_name = 'v1.0.6'
    target_commitish = os.environ['TARGET_SHA']
    body = 'Release notes here'

    create_github_release(token, repository, tag_name, release_name, target_commitish, body)

